class AddUrls < ActiveRecord::Migration
  def change
    # TODO should it use MyISAM?
    # create_table :hits, options: 'DEFAULT CHARSET=utf8 COLLATE=utf8_bin ENGINE=MyISAM' do |t|
    create_table :urls, options: 'DEFAULT CHARSET=utf8 COLLATE=utf8_bin ENGINE=MyISAM' do |t|
      t.references :host, null: false
      t.string :path, null: false, limit: 1024
      t.string :path_hash, null: false, limit: 40
    end
    add_index :urls, [:host_id, :path_hash], unique: true
    add_index :urls, [:host_id]
  end
end
