# encoding: UTF-8

class LocalityGroup
  belongs_to :administrative_area
  has_many :localities
  has_many :locations
end
