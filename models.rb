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

# require all models
require_relative 'models/job_posting'
