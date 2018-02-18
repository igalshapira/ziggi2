class CreateGroupHours < ActiveRecord::Migration
  def change
    create_table :group_hours do |t|
      t.integer :coursegroup_id
      t.integer :day
      t.float :start
      t.float :end

      t.timestamps
    end
  end
end
