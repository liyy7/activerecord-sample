# encoding: UTF-8

require_relative 'bit_column_model'

class JobPosting
  class OfferType
    include JobPosting::BitColumnModel

    VALUES = %w(
      fulltime
      contract
      parttime
      temporary
      other
    )
  end
end
