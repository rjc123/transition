class RelateMappingsToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :mapping_id, :integer

    add_index :urls, :mapping_id
  end
end
