class RenameStagingColumns < ActiveRecord::Migration
  def up
    execute <<-postgreSQL
      CREATE EXTENSION IF NOT EXISTS pgcrypto
    postgreSQL
    rename_column :mappings_staging, :http_status, :status
    rename_column :mappings_staging, :suggested_url, :suggested_link
    rename_column :mappings_staging, :archive_url, :archive_link
  end

  def down
    execute <<-postgreSQL
      DROP EXTENSION IF EXISTS pgcrypto
    postgreSQL
    rename_column :mappings_staging, :status, :http_status
    rename_column :mappings_staging, :suggested_link, :suggested_url
    rename_column :mappings_staging, :archive_link, :archive_url
  end
end
