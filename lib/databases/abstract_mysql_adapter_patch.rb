# encoding: UTF-8

require 'helper'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
      def execute(sql, name = nil)
        Helper::get_logger.debug('SQL') { sql }
        Helper::time('QUERY') { @connection.query sql }
      end
    end
  end
end
