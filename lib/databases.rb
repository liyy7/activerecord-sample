# encoding: UTF-8

require 'bundler/setup'
require 'active_record'
require 'yaml'

ActiveRecord::Base.logger = Logger.new(STDOUT) if $ACTIVE_DEBUG

db_config = YAML.load_file File.expand_path('../../config/database.yml', __FILE__)

ActiveRecord::Base.configurations = db_config

class ActiveRecord::Base
  class << self
    alias origin_connection connection

    def connection
      if defined?(Database)
        establish_connection Database.connection_config
      else
        establish_connection
      end
      origin_connection
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
