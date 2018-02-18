class GroupHours < ActiveRecord::Base
  attr_accessible :coursegroup_id, :room, :date_start, :date_end, :building_id, :room_number
  belongs_to :course_groups
end
