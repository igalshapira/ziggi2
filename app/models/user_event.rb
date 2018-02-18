class UserEvent < ActiveRecord::Base
  attr_accessible :event_id, :selected, :user_id
  belongs_to :user
  belongs_to :event
end
