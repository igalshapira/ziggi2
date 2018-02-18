class AddColorAndCourseToEvents < ActiveRecord::Migration
  def change
      remove_column :events, :search
      add_column :events, :title, :string
      add_column :events, :color, :integer
      add_column :events, :course_id, :integer
  end
end
