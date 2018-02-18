class Share < ActiveRecord::Base
  attr_accessible :share_hash, :user_id
  belongs_to :user
end
