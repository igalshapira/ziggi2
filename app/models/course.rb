class Course < ActiveRecord::Base
  attr_accessible :json, :name, :number, :semester_id, :points, :hours, :homepage, :updated_at
  has_many :user_courses
  has_many :course_groups
  has_many :exams
  has_many :events
  belongs_to :semester
end
