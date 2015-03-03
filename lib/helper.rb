class Logging
  def self.log(s)
    puts "#{Time.now} >> #{s}" unless ENV['NO_LOG']
  end
end

def time(label = nil)
  fail 'Need block as timing target' unless block_given?

  t = Time.now
  res = yield
  Logging.log "~~~ Time - #{Time.now - t} label{#{label}} ~~~"
  res
end

def define_tables(database)
  database.connection.tables.each do|t_name|
    klass_name = t_name.camelize
    klass = Class.new database do
      self.table_name = t_name
    end
    Object.const_set klass_name, klass
  end
end
