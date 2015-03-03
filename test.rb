#!/usr/bin/env ruby
# encoding: UTF-8

lib_path = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include? lib_path

$ACTIVE_DEBUG = false

require 'helper'
require 'databases'

Database = StagingDatabase

define_tables Database

class Location
  def filtered_attrs
    attributes.tap { |attrs| attrs.delete 'id' }.select { |_, v| !v.nil? }
  end
end

def create_loc_dups(locs)
  @created_cnt = @created_cnt ? @created_cnt : 0

  LocationDup.connection_pool.with_connection do
    locs.each do|loc|
      begin
        LocationDup.create loc.filtered_attrs
        Logging.log "#{@created_cnt += 1} loc dups created"
      rescue StandardError => err
        Logging.log err.inspect
      end
    end
  end
end

def try_checkout_conn_from(db)
  Thread.new do
    loop do
      begin
        db.connection_pool.with_connection { |c| c } && break
      rescue ActiveRecord::ConnectionTimeoutError => err
        Logging.log err.inspect
      end
    end
  end.join
end

def main
  threads = []

  batch_cnt = 0

  Location.find_in_batches do|locs|
    batch_cnt += 1
    time("check available database connection batch_#{batch_cnt}") { try_checkout_conn_from LocationDup }
    threads << Thread.new do
      time("create #{locs.size} loc dups batch_#{batch_cnt}") { create_loc_dups locs }
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
