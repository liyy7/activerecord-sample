# encoding: UTF-8

require_relative 'bit_column_model'

class JobPosting
  class Feature
    include JobPosting::BitColumnModel

    VALUES = %w(
      childsupport
      dailypayment
      homemaker
      noexperience
      nooverwork
      restonweekend
      shortterm
      student
    )
  end
end
