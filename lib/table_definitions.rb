# encoding: UTF-8

require_relative 'belongs_to_reflection_patch'


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
  belongs_to :country, { invalid_ids: [0] }
  belongs_to :administrative_area, { invalid_ids: [0] }
  belongs_to :locality_group, { invalid_ids: [0] }
  belongs_to :locality, { invalid_ids: [0] }
  belongs_to :ward, { invalid_ids: [0] }

  include BelongsToReflectionPatch
end

class Station
  has_many :nearest_stations
  belongs_to :administrative_area
end

class NearestStation
  belongs_to :job_posting
  belongs_to :station
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

  def like?
    type == :LIKE
  end

  def dislike?
    type == :DISLIKE
  end
end

class User
  has_many :likes
end
