class AddStatusToUniversties < ActiveRecord::Migration
  def change
      add_column :universities, :status, :integer, :default => 0
  end
end
