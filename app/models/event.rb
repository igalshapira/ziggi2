class Event < ActiveRecord::Base
  attr_accessible :location, :title, :university_id, :user_id, :color, :course_id, :date_start, :date_end, :public, :weekly, :staff_id
  validates :title, :presence => true
  belongs_to :user
  belongs_to :course
  belongs_to :staff
  has_many :user_events, :dependent => :destroy
end
