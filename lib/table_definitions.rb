# encoding: UTF-8

module JobPosting::TitledAttribute
  def self.included(klass)
    klass.include Methods
    klass.extend ClassMethods
  end

  module Methods
    attr_accessor :job_posting_id
    attr_reader :title

    def initialize(attrs = {})
      fail 'Hash required' unless attrs.is_a?(Hash)

      self.job_posting_id = attrs['job_posting_id'] || attrs[:job_posting_id]
      self.title = attrs['title'] || attrs[:title]
    end

    def title=(t)
      fail "Invalid title '#{t}'" unless (t.nil? || class_eval('TITLES').include?(t))

      @title = t
    end
  end

  module ClassMethods
    def from_bits(bits)
      i = bits_i(bits)

      class_eval('TITLES')
      .each_with_index
      .select { |t, idx| 1 << idx & i > 0 }
      .collect(&:first)
      .map { |t| self.new(title: t) }
    end

    private
    def bits_i(bits)
      bits.bytes.inject { |r, ele| r * 256 + ele }
    end
  end
end

class OfferType
  include JobPosting::TitledAttribute

  TITLES = %w(
    fulltime
    contract
    parttime
    temporary
    other
  )
end

class Feature
  include JobPosting::TitledAttribute

  TITLES = %w(
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

class Country
  has_many :administrative_areas
  has_many :locations
end

class AdministrativeArea
  belongs_to :country
  has_many :locality_groups
  has_many :localities
  has_many :locations
end

class LocalityGroup
  belongs_to :administrative_area
  has_many :localities
  has_many :locations
end

class Locality
  belongs_to :administrative_area
  belongs_to :locality_group
  has_many :wards
  has_many :locations
end

class Ward
  belongs_to :locality
  has_many :locations
end

class Location
  belongs_to :job_posting
  belongs_to :country
  belongs_to :administrative_area
  belongs_to :locality_group
  belongs_to :locality
  belongs_to :ward
end

class Station
  has_many :nearest_stations
  belongs_to :administrative_area
end

class NearestStation
  belongs_to :job_posting
  belongs_to :station
end

class JobPosting
  has_many :locations
  has_many :nearest_stations

  def offer_types
    OfferType.from_bits(offer_type_bit).map { |o| o.job_posting_id = id; o }
  end

  def features
    Feature.from_bits(feature_bit).map { |f| f.job_posting_id = id; f }
  end
end

class Like
  belongs_to :job_posting
  belongs_to :user

  self.inheritance_column = :_type_disabled

  TYPES = {
    1 => :LIKE,
    2 => :DISLIKE
  }

  def type
    TYPES[attributes['type']]
  end

  def is_like?
    type == :LIKE
  end

  def is_dislike?
    type == :DISLIKE
  end
end

class User
  has_many :likes
end
