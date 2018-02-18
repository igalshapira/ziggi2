class User < ActiveRecord::Base
  attr_accessible :email, :gender, :name, :semester_id, :university_id, :logins
  has_many :authorizations
  has_many :user_courses
  has_many :user_groups
  has_many :staff
  has_many :events
  has_many :user_events
  has_many :staff_ranks
  has_one :share
  belongs_to :university
  belongs_to :semester
  validates :name, :email, :presence => true
end
