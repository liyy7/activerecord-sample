# encoding: UTF-8

class AdministrativeArea
  belongs_to :country
  has_many :locality_groups
  has_many :localities
  has_many :locations
end
