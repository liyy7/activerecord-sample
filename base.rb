# encoding: UTF-8

fail "Do not run #{__FILE__} directly, please require it" if __FILE__ == $PROGRAM_NAME

require 'bundler/setup'

lib_path = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'awesome_print'
require 'helper'
require 'databases'

include Helper

ActiveRecord::Base.logger = get_logger

define_tables(JobPostingDatabase, OAuthDatabase) { require 'table_definitions' }
