class AddDateToEvent < ActiveRecord::Migration
  def change
      add_column :events, :date_start, :datetime
      add_column :events, :date_end, :datetime
  end
end
