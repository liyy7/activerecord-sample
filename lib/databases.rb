# encoding: UTF-8

require 'active_record'
require 'yaml'

ActiveRecord::Base.configurations =
  YAML.load_file(File.expand_path('../../config/database.yml', __FILE__))

# Use :default_env
ActiveRecord::Base.establish_connection

# This patch need to be required after establish_connection
require_relative 'patchs/abstract_mysql_adapter'

class JobPostingDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :job_posting
end

class OAuthDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :oauth
end
