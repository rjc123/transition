class RelateHitsToUrls < ActiveRecord::Migration
  def change
    add_column :hits, :url_id, :integer
    add_index :hits, [:url_id]
  end
end
