class SearchsResultsToNoLimit < ActiveRecord::Migration
  def change
      change_column :searches, :results, :text, :limit => nil
  end
end
