#!/usr/bin/env ruby
# encoding: UTF-8

require_relative 'base'

def update_job_postings(records)
  @updated_cnt = @updated_cnt ? @updated_cnt : 0

  JobPosting.connection_pool.with_connection do
    records.group_by(&:job_posting_id).each do |job_posting_id, recs|
      begin
        JobPosting.new(id: job_posting_id).update_bit_coloumns_by_records recs
        Logging.log "#{@updated_cnt += recs.size} JobPostings updated"
      rescue StandardError => err
        Logging.log err.inspect
      end
    end
  end
end

def main
  threads = []

  batch_cnt = 0

  tables = [OfferType, Feature]

  find_in_batches(tables.sample, order_by: :job_posting_id) do |records|
    batch_cnt += 1
    time("check available database connection batch_#{batch_cnt}") { try_checkout_conn_from JobPosting }

    threads << Thread.new do
      time("update #{records.size} JobPostings batch_#{batch_cnt}") { update_job_postings records }
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
