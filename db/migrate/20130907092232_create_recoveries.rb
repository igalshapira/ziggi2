class CreateRecoveries < ActiveRecord::Migration
  def change
    create_table :recoveries do |t|
      t.integer :user_id
      t.string :recover_hash

      t.timestamps
    end
  end
end
