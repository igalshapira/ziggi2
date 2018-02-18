class BeerNotification < ActiveRecord::Base
  attr_accessible :params, :status, :user_id
  belongs_to :user
  serialize :params
end
