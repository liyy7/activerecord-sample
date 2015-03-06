#!/usr/bin/env ruby
# encoding: UTF-8

lib_path = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include? lib_path

$ACTIVE_DEBUG = false

require 'helper'
require 'databases'

Database = StagingDatabase

define_tables Database

class OfferType
  OFFER_TYPES = %w(
    fulltime
    contract
    parttime
    temporary
    other
  )

  def bit
    1 << OFFER_TYPES.index(offer_type)
  end
end

class Feature
  TITLES = %w(
    childsupport
    dailypayment
    homemaker
    noexperience
    nooverwork
    restonweekend
    shortterm
    student
  )

  def bit
    1 << TITLES.index(title)
  end
end

class JobPosting
  # TODO: for test
  self.table_name = 'job_posting_new'

  has_many :offer_types, class_name: OfferType
  has_many :features, class_name: Feature

  def built_offer_type_bit
    offer_types.map(&:bit).inject { |m, o| m | o }
  end

  def built_feature_bit
    features.map(&:bit).inject { |m, o| m | o }
  end

  def update_bit_coloumns(attrs)
    bit_attrs = attrs
    .select { |k, v| v.is_a? Integer }
    .map { |k, v| [k, [v].pack('c*')] }
    .to_h

    bit_attrs.empty? || update(bit_attrs)
  end

  def empty_bit_coloumn?(coloum)
    !attributes[coloum.to_s].bytes.any? { |b| b > 0 }
  end
end

def update_job_postings(job_postings)
  return if job_postings.empty?

  @updated_cnt = @updated_cnt ? @updated_cnt : 0

  JobPosting.connection_pool.with_connection do
    job_postings = JobPosting
    .includes(:offer_types, :features)
    .select(:id)
    .where(id: job_postings.collect(&:id))
    .all
    .reject { |j| j.offer_types.empty? && j.features.empty? }

    Logging.log "#{job_postings.size} JobPostings may be updated"

    job_postings.each do|job_posting|
      begin
        job_posting.update_bit_coloumns(
          offer_type_bit: job_posting.built_offer_type_bit,
          feature_bit: job_posting.built_feature_bit)

        Logging.log "#{@updated_cnt += 1} JobPostings updated"
      rescue StandardError => err
        Logging.log err.inspect
      end
    end
  end
end

def main
  threads = []

  batch_cnt = 0
  batch_size = 1000

  (0 .. JobPosting.count).each_slice(batch_size) do |slice|
    job_postings = JobPosting
    .select(:id, :offer_type_bit, :feature_bit)
    .limit(batch_size)
    .offset(slice.first)
    .all
    .select { |j| j.empty_bit_coloumn?(:offer_type_bit) && j.empty_bit_coloumn?(:feature_bit) }

    batch_cnt += 1
    time("check available database connection batch_#{batch_cnt}") { try_checkout_conn_from JobPosting }

    threads << Thread.new do
      time("update #{job_postings.size} JobPostings batch_#{batch_cnt}") { update_job_postings job_postings }
    end
  end

  Logging.log "generated #{threads.size} threads"

  threads.each do|t|
    begin
      t.join
    rescue StandardError => err
      Logging.log err.inspect
    end
  end
end

time('main call') { main } if __FILE__ == $PROGRAM_NAME
