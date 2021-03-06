class CreateHostPaths < ActiveRecord::Migration
  def change
    create_table :host_paths, options: 'DEFAULT CHARSET=utf8 COLLATE=utf8_bin ENGINE=MyISAM' do |t|
      t.string :path, limit: 2048
      t.string :path_hash
      t.string :c14n_path_hash

      t.references :host
      t.references :mapping
    end

    add_index :host_paths, [:host_id, :path_hash], unique: true # Used only for INSERT IGNORE
    add_index :host_paths, :c14n_path_hash                      # Used for lookup when creating/editing mappings
    add_index :host_paths, :mapping_id
  end
end
