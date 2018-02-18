class ReCreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.integer :user_id
      t.string :share_hash

      t.timestamps
    end
  end
end
