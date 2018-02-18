class Semester < ActiveRecord::Base
  attr_accessible :end, :name, :semester, :start, :university_id, :year, :exams_start, :exams_end, :active
  has_many :users
  belongs_to :university
end
