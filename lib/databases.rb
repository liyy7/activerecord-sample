# encoding: UTF-8

require 'bundler/setup'
require 'active_record'
require 'yaml'

ActiveRecord::Base.logger = Logger.new(STDOUT) if $ACTIVE_DEBUG

db_config = YAML.load_file File.expand_path('../../config/database.yml', __FILE__)

ActiveRecord::Base.configurations = db_config

module ActiveRecord
  class Base
    class << self
      attr_reader :established
      alias_method :established?, :established

      def custom_establish_connection
        if defined?(Database)
          establish_connection Database.connection_config
        else
          establish_connection
        end

        @established = true
      end

      def establish_connection_if_neccessary
        custom_establish_connection if self == ActiveRecord::Base && !established?
      end

      private :custom_establish_connection, :establish_connection_if_neccessary

      alias_method :origin_connection, :connection
      alias_method :origin_connection_pool, :connection_pool

      def connection
        establish_connection_if_neccessary
        origin_connection
      end

      def connection_pool
        establish_connection_if_neccessary
        origin_connection_pool
      end
    end
  end
end

class DevelopmentDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :development
end

class StagingDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :staging
end

class ProductionDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :production
end

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
      def execute(sql, name = nil)
        ::Logging.log ">> Executing - sql{#{sql[0, 200]}}, name{#{name}}"
        @connection.query sql
      end
    end
  end
end
