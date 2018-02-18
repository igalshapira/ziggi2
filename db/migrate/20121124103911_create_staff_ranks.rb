class CreateStaffRanks < ActiveRecord::Migration
  def change
    create_table :staff_ranks do |t|
      t.integer :staff_id
      t.integer :user_id
      t.integer :rank
      t.string :comment

      t.timestamps
    end
  end
end
