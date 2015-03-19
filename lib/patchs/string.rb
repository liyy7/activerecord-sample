# encoding: UTF-8

require 'anbt-sql-formatter/formatter'

class String
  def pretty_formatted_sql
    @sql_formatter ||= begin
                         rule = AnbtSql::Rule.new
                         rule.indent_string = '  '
                         AnbtSql::Formatter.new rule
                       end
    @sql_formatter.format self.clone
  end
end
