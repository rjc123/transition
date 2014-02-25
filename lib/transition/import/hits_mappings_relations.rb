require 'optic14n'

module Transition
  module Import
    class HitsMappingsRelations
      ##
      #
      # Simulation of FIRST via GROUP_CONCAT
      # http://stackoverflow.com/questions/13957082/selecting-first-and-last-values-in-a-group
      # USE INDEX hint also necessary to avoid query running till heat
      # death of universe (it'll still take a couple of minutes).
      #
      # mySQL, you need to stop hiding Smirnoff in the cornflakes.
      #
      REFRESH_SITE_PATHS = <<-mySQL
        INSERT IGNORE INTO site_paths(site_id, path_hash, path)
        SELECT sites.id,
               hits.path_hash,
               SUBSTRING_INDEX(GROUP_CONCAT(CAST(path AS CHAR)), ',', 1) # Simulate FIRST()
               AS path
        FROM   hits USE INDEX (index_hits_on_host_id_and_path_hash_and_hit_on_and_http_status)
               JOIN hosts ON hosts.id = hits.host_id
               JOIN sites ON sites.id = hosts.site_id
        GROUP  BY hits.host_id,
                  hits.path_hash
      mySQL

      REFRESH_HITS_FROM_SITE_PATHS = <<-mySQL
        UPDATE hits
        INNER JOIN site_paths ON site_paths.path_hash = hits.path_hash
        SET hits.mapping_id = site_paths.mapping_id
        WHERE site_paths.mapping_id IS NOT NULL
      mySQL

      ##
      # A three-step refresh:
      #
      # 1. Refresh site_paths with INSERT IGNORE
      # 2. Fill in the site_paths.mapping_id for all rows where missing
      #    (using find_each, default batch size of 1000)
      # 3. Update hits with the mapping_id from site_paths
      def self.refresh!
        Rails.logger.info 'Refreshing site paths...'
        ActiveRecord::Base.connection.execute(REFRESH_SITE_PATHS)

        Rails.logger.info 'Adding missing mapping IDs to site paths...'
        SitePath.where(mapping_id: nil).includes(:site).find_each do |site_path|
          site = site_path.site

          c14nized_path_hash =
            Digest::SHA1.hexdigest(site.canonical_path(site_path.path))
          mapping_id = Mapping.where(
            path_hash: c14nized_path_hash, site_id: site.id).pluck(:id).first
          site_path.update_column(
            :mapping_id, mapping_id) if mapping_id && (site_path.mapping_id != mapping_id)
        end

        Rails.logger.info 'Updating hits from site paths...'
        ActiveRecord::Base.connection.execute(REFRESH_HITS_FROM_SITE_PATHS)
      end

    end
  end
end
