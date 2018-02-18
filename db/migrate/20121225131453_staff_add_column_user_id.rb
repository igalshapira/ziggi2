class StaffAddColumnUserId < ActiveRecord::Migration
  def change
      add_column :staffs, :user_id, :integer, :default => 0
  end
end
