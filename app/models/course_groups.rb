class CourseGroups < ActiveRecord::Base
  attr_accessible :course_id, :number, :staff_id, :group_type
  has_many :group_hours
  belongs_to :course
  belongs_to :staff
end
