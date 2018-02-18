class UserCourse < ActiveRecord::Base
  attr_accessible :course_id, :user_id, :group
  belongs_to :course
end
