# encoding: UTF-8

class Logging
  def self.log(s)
    STDOUT.puts "#{Time.now} >> #{s}" unless ENV['NO_LOG']
    STDOUT.flush
  end
end

def time(label = nil)
  fail 'Block required' unless block_given?

  t = Time.now
  res = yield
  Logging.log "~~~ Time - #{Time.now - t} label{#{label}} ~~~"
  res
end

def define_tables(*databases)
  databases.each do |db|
    db.connection.tables.each do|table|
      klass = Class.new(db) { self.table_name = table }
      Object.const_set table.camelize, klass
    end
  end

  yield if block_given?
end

def wait_for_available_connection(database)
  Thread.new do
    loop do
      begin
        database.connection_pool.with_connection { |c| c } && break
      rescue ActiveRecord::ConnectionTimeoutError => err
        Logging.log err.inspect
      end
    end
  end.join
end

def find_in_batches(table, options = {}, batch_size = 5000)
  fail 'Block required' unless block_given?

  (0..table.count).each_slice(batch_size) do |slice|
    query = table
    query = options[:order_by].nil? ? query : query.order(options[:order_by])
    query = query.limit(batch_size).offset(slice.first)
    records = query.all
    yield records
  end
end

class String
  require 'anbt-sql-formatter/formatter'
  def pretty_formatted_sql
    @sql_formatter ||= begin
                         rule = AnbtSql::Rule.new
                         rule.indent_string = '  '
                         AnbtSql::Formatter.new rule
                       end
    @sql_formatter.format self.clone
  end
end
