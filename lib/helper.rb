# encoding: UTF-8

require 'logger'
require 'awesome_print'
require_relative 'patchs/string'

module Helper
  module_function

  def get_logger
    $logger ||= begin
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

  def interpreter?
    defined?(IRB) || defined?(Pry)
  end
end
