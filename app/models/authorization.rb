class Authorization < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id
  belongs_to :user
  validates :user_id, :provider, :uid, :presence => true

  def self.find_or_create(auth_hash)
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      user = User.find_by_email(auth_hash["info"]["email"])
      if not user
        semester = Semester.find_by_university_id_and_active(1, true)
        user = User.new :name => auth_hash["info"]["name"], :email => auth_hash["info"]["email"], :gender => auth_hash["extra"]["raw_info"]["gender"], :semester_id => semester.id
        user.save
      end

      auth = Authorization.new :user_id => user.id, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
      auth.save
    end
    auth
  end
end
