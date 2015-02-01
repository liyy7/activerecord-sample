#!/usr/bin/env ruby
# encoding: UTF-8

def time
  t = Time.now
  res = yield
  puts "~~~ Time: #{Time.now - t} ~~~"
  res
end

class Logging
  def self.log(s)
    puts s
  end
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
  LocationDup.connection_pool.with_connection do
    locs.each do|loc|
      begin
        LocationDup.create loc.filtered_attrs
      rescue StandardError => err
        Logging.log err.inspect
      end
    end
  end
end

def main
  threads = []

  Location.find_in_batches { |locs| threads << Thread.new { create_loc_dups locs } }

  threads.each do|t|
    begin
      t.join
    rescue StandardError => err
      Logging.log err.inspect
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
