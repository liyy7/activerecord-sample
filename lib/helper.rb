# encoding: UTF-8

require 'logger'
require 'awesome_print'
require_relative 'string_patch'

module Helper
  def get_logger
    @logger ||= begin
                  target = interpreter? ? STDOUT : "logs/#{Time.now.to_s.gsub(/[- :+]/, '')}.log"
                  Logger.new(target).tap do |logger|
                    logger.formatter = proc do |severity, time, progname, msg|
                      msg = case progname
                      when 'SQL'
                        msg = msg.pretty_formatted_sql if msg.respond_to?(:pretty_formatted_sql)
                        msg = msg.yellow if msg.respond_to?(:yellow)
                        "\n#{msg}"
                      else
                        msg
                      end
                      "#{severity.each_char.first} [#{time.to_s}] -- #{progname}: #{msg}\n"
                    end
                  end
                end
  end

  def time(label = '')
    fail('Block required') unless block_given?

    t = Time.now
    r = yield
    get_logger.info('TIME') { "#{label}~ #{Time.now - t}s" }
    r
  end

  private

  def interpreter?
    defined?(IRB) || defined?(Pry)
  end
end

  ###
  class Logging
    def self.log(s)
      STDOUT.puts "#{Time.now} >> #{s}" unless ENV['NO_LOG']
      STDOUT.flush
    end
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
