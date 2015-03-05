#!/usr/bin/env ruby
# encoding: UTF-8

OFFER_TYPES = %w(
  fulltime
  contract
  parttime
  temporary
  other
)

def build_bit(offer_type)
  1 << OFFER_TYPES.index(offer_type)
end

lib_path = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include? lib_path

$ACTIVE_DEBUG = false

require 'helper'
require 'databases'

Database = StagingDatabase

define_tables Database

def update_offer_type_bits(offer_types)
  @updated_cnt = @updated_cnt ? @updated_cnt : 0

  JobPosting.connection_pool.with_connection do
    offer_types.each do|offer_type|
      begin
        bit = build_bit offer_type.title
        JobPosting.where(id: offer_type.job_posting_id).update_all("offer_type_bit = offer_type_bit | #{bit}")
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

  #find_in_batches(OfferType) do |offer_types|
  [offer_type.take(10)].each do |offer_types|
    batch_cnt += 1
    time("check available database connection batch_#{batch_cnt}") { try_checkout_conn_from JobPosting }
    threads << Thread.new do
      time("update #{offer_types.size} JobPostings batch_#{batch_cnt}") { update_offer_type_bits offer_types }
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
