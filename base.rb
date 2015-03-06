# encoding: UTF-8

fail "do not run #{__FILE__}, require it" if __FILE__ == $PROGRAM_NAME

lib_path = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include? lib_path

$ACTIVE_DEBUG = false

require 'helper'
require 'databases'

Database = StagingDatabase

define_tables(Database) { require 'table_definitions' }
