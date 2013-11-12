class RenameStagingColumns < ActiveRecord::Migration
  def up
    execute <<-postgreSQL
      CREATE EXTENSION IF NOT EXISTS pgcrypto
    postgreSQL
    rename_column :mappings_staging, :http_status, :status
    rename_column :mappings_staging, :suggested_url, :suggested_link
    rename_column :mappings_staging, :archive_url, :archive_link

    rename_column :hits_staging, :http_status, :status
    rename_column :hits_staging, :hit_on, :date
    rename_column :hits_staging, :hostname, :host

    change_column :hits_staging, :path, :string, limit: 2048
    change_column :hits, :path, :string, limit: 2048
  end

  def down
    execute <<-postgreSQL
      DROP EXTENSION IF EXISTS pgcrypto
    postgreSQL
    rename_column :mappings_staging, :status, :http_status
    rename_column :mappings_staging, :suggested_link, :suggested_url
    rename_column :mappings_staging, :archive_link, :archive_url

    rename_column :hits_staging, :status, :http_status
    rename_column :hits_staging, :date, :hit_on
    rename_column :hits_staging, :host, :hostname

    change_column :hits_staging, :path, :string, limit: 1024
    change_column :hits, :path, :string, limit: 1024

  end
end
