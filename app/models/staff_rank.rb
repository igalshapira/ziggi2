class StaffRank < ActiveRecord::Base
  attr_accessible :comment, :rank, :staff_id, :user_id
  belongs_to :user
end
