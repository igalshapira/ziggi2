class Staff < ActiveRecord::Base
  attr_accessible :reception, :email, :name, :phone, :room, :user_id
  has_many :course_group
  belongs_to :user
  has_many :events

  def self.find_or_create(name)
    unless staff = Staff.find_by_name(name)
      staff = Staff.new :name => name
      staff.save
    end
    staff
  end

end
