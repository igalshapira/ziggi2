class AddUserIdToUserEvents < ActiveRecord::Migration
  def change
      add_column :user_events, :user_id, :integer
  end
end
