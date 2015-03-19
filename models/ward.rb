# encoding: UTF-8

class Ward
  belongs_to :locality
  has_many :locations
end
