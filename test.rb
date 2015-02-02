#!/usr/bin/env ruby
# encoding: UTF-8

class Logging
  def self.log(s)
    puts s unless ENV['NO_LOG']
  end
end

def time(label = nil)
  t = Time.now
  res = yield
  Logging.log "~~~ Time - #{Time.now - t} label{#{label}} ~~~"
  res
end

$ACTIVE_DEBUG = false

require './lib/databases'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      def execute(sql, name = nil)
        ::Logging.log ">> Executing - sql{#{sql}}, name{#{name}}"
        @connection.query sql
      end
    end
  end
end

Database = StagingDatabase

Database.connection.tables.each do|t_name|
  klass_name = t_name.camelize
  klass = Class.new Database do
    self.table_name = t_name
  end
  Object.const_set klass_name, klass
end

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
