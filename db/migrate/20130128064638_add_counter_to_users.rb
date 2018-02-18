class AddCounterToUsers < ActiveRecord::Migration
  def change
      add_column :users, :logins, :integer, :default => 1
  end
end
