class GroupHoursAddRoom < ActiveRecord::Migration
  def change
      add_column :group_hours, :room, :string
  end
end
