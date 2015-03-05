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

def try_checkout_conn_from(db)
  Thread.new do
    loop do
      begin
        db.connection_pool.with_connection { |c| c } && break
      rescue ActiveRecord::ConnectionTimeoutError => err
        Logging.log err.inspect
      end
    end
  end.join
end

def find_in_batches(table, batch_size = 5000)
  (0 .. table.count).each_slice(batch_size) do |slice|
    records = table.limit(batch_size).offset(slice.first).all
    yield records
  end
end
