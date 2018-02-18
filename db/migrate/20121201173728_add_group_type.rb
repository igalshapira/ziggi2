class AddGroupType < ActiveRecord::Migration
  def change
      add_column :course_groups, :type, :string
  end
end
