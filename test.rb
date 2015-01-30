#!/usr/bin/env ruby
# encoding: UTF-8

$ACTIVE_DEBUG = true

require './lib/databases'

Database = StagingDatabase

class Location < Database
  self.table_name = 'location'
end

class LocationDup < Database
  self.table_name = 'location_dup'
end

if __FILE__ == $0

  $unique_err_cnt = 0

  Location.find_each do|loc|
    attrs = loc.attributes
    attrs.delete('id')
    attrs = attrs.select { |k,v| !v.nil? }

    begin
      LocationDup.create attrs
    rescue ActiveRecord::RecordNotUnique => e
      p e
      $unique_err_cnt += 1
      puts 'ActiveRecord::RecordNotUnique count up'
    rescue Exception => e
      p e
    end
  end

  puts "ActiveRecord::RecordNotUnique: #{$unique_err_cnt}"

end
