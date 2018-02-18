class DeleteLoginsFromUsers < ActiveRecord::Migration
  def change
      remove_column :users, :logins
  end
end
