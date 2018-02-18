class CourseRemoveJson < ActiveRecord::Migration
  def change
      remove_column :courses, :json
  end
end
