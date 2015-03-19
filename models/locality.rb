# encoding: UTF-8

class Locality
  belongs_to :administrative_area
  belongs_to :locality_group
  has_many :wards
  has_many :locations
end
