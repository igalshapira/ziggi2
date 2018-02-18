class RemoveContentFromEvent < ActiveRecord::Migration
  def change
      remove_column :events, :content
  end
end
