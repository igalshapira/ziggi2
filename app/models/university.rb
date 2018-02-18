class University < ActiveRecord::Base
  # status => 1 -> hidden, 1 => active,
  attr_accessible :code, :homepage, :lat, :lng, :name, :status
  has_many :user
  has_many :semester
end
