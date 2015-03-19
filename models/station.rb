# encoding: UTF-8

class Station
  has_many :nearest_stations
  belongs_to :administrative_area
end
