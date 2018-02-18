class Recovery < ActiveRecord::Base
  attr_accessible :recover_hash, :user_id
end
