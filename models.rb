# encoding: UTF-8

require 'helper'
require 'databases'

# As table name may have no 's' suffix, this code will handle it well
[JobPostingDatabase, OAuthDatabase].each do |database|
  database.connection.tables.each do |table_name|
    klass = Class.new(database)
    klass.table_name = table_name
    Object.const_set table_name.camelize, klass
  end
end

# Require all models
require_relative 'models/job_posting'
require_relative 'models/location'
require_relative 'models/country'
require_relative 'models/administrative_area'
require_relative 'models/locality_group'
require_relative 'models/locality'
require_relative 'models/ward'
require_relative 'models/nearest_station'
require_relative 'models/station'
require_relative 'models/like'
require_relative 'models/user'
