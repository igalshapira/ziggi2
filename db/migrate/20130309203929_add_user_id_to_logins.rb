class AddUserIdToLogins < ActiveRecord::Migration
  def change
      add_column :logins, :user_id, :integer
      remove_column :logins, :referrer
  end
end
