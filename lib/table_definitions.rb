# encoding: UTF-8

class JobPosting
  has_many :locations, class_name: Location
  has_many :nearest_stations, class_name: NearestStation
end
