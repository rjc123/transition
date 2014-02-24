class CreateSitePaths < ActiveRecord::Migration
  def change
    create_table :site_paths, options: 'DEFAULT CHARSET=utf8 COLLATE=utf8_bin ENGINE=MyISAM' do |t|
      t.string :path, limit: 2048
      t.string :path_hash
      t.references :site
      t.references :mapping
    end

    add_index :site_paths, [:site_id, :path_hash], unique: true # Used only for INSERT IGNORE
    add_index :site_paths, :mapping_id
  end
end
