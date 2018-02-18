class FixBadAuth < ActiveRecord::Migration
  def change
      Authorization.find_all_by_user_id(nil).each do |a|
	  a.destroy
      end
  end
end
