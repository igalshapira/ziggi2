class CreateStaffs < ActiveRecord::Migration
  def change
    create_table :staffs do |t|
      t.string :name
      t.string :phone
      t.string :room
      t.string :email

      t.timestamps
    end
  end
end
