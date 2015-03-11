# encoding: UTF-8

fail "Do not run #{__FILE__} directly, please require it" if __FILE__ == $PROGRAM_NAME

lib_path = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'helper'
require 'databases'

Database = ProductionDatabase

define_tables(Database) { require 'table_definitions' }
