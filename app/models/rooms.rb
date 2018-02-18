class Rooms < ActiveRecord::Base
  attr_accessible :comment, :lat, :lng, :name, :university_id
end
