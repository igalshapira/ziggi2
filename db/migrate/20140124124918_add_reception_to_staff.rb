class AddReceptionToStaff < ActiveRecord::Migration
  def change
    add_column :staffs, :reception, :string
  end
end
