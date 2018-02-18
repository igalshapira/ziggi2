class AddStaffName < ActiveRecord::Migration
  def change
      add_column :course_groups, :staff_name, :string
      remove_column :course_groups, :staff_id
  end
end
