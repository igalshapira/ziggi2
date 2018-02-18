class Logins < ActiveRecord::Base
  attr_accessible :browser, :ip, :provider, :user_id
  belongs_to :user
end
