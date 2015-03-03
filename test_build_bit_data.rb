#!/usr/bin/env ruby
# encoding: UTF-8

lib_path = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include? lib_path

$ACTIVE_DEBUG = false

require 'helper'
require 'databases'

Database = StagingDatabase

define_tables Database

def main
  # TODO: build bit data
end

time('main call') { main } if __FILE__ == $PROGRAM_NAME
