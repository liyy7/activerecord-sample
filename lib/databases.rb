# encoding: UTF-8

require 'active_record'
require 'yaml'

ActiveRecord::Base.configurations =
  YAML.load_file(File.expand_path('../../config/database.yml', __FILE__))

# Use :default_env
ActiveRecord::Base.establish_connection

class JobPostingDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :job_posting
end

class OAuthDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :oauth
end

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
      def execute(sql, name = nil)
        respond_to?(:get_logger) && get_logger.debug('SQL') { sql }
        respond_to?(:time) ? time('QUERY') { @connection.query sql } : @connection.query(sql)
      end
    end
  end
end
