module Transition
  module Import
    class Mappings
      TRUNCATE = <<-postgreSQL
        TRUNCATE mappings_staging
      postgreSQL

      LOAD_DATA = <<-postgreSQLTemplate
        COPY mappings_staging ($fieldlist$)
        FROM '$filename$' WITH CSV HEADER
      postgreSQLTemplate

      SPLIT_OUT_HOST_AND_PATH = <<-postgreSQL
        UPDATE mappings_staging
        SET    host = regexp_replace(old_url, '(http://)|(/.*)', '', 'g'),
               path = '/' || regexp_replace(old_url, '.*?//.*?/', '', 'g'),
               path_hash = encode(digest('/' || regexp_replace(old_url, '.*?//.*?/', '', 'g'), 'sha1'), 'hex')
      postgreSQL

      UPDATE_FROM_STAGING = <<-postgreSQL
        UPDATE mappings
        SET http_status   = st.status,
            new_url       = st.new_url,
            suggested_url = st.suggested_link,
            archive_url   = st.archive_link
        FROM
          mappings_staging st
        INNER JOIN
          hosts h on h.hostname = st.host
        WHERE
          mappings.site_id = h.site_id AND mappings.path = st.path
      postgreSQL

      INSERT_FROM_STAGING = <<-postgreSQL
        INSERT INTO mappings (site_id, path, path_hash, http_status, new_url, suggested_url, archive_url)
        SELECT
          h.site_id, st.path, st.path_hash, st.status, st.new_url, st.suggested_link, st.archive_link
        FROM
          mappings_staging st
        INNER JOIN hosts h on h.hostname = st.host
        WHERE NOT EXISTS (SELECT 1 FROM mappings WHERE path = st.path AND site_id = h.site_id)
      postgreSQL

      def self.field_list(filename)
        File.open(filename, &:readline).chomp.split(',').map { |s| s.downcase.gsub(' ', '_') }.join(',')
      end

      def self.from_redirector_csv_file!(filename)
        $stderr.print "Importing #{filename} ... "
        [
          TRUNCATE,
          LOAD_DATA.sub('$filename$', "#{File.expand_path(filename)}").sub('$fieldlist$', field_list(filename)),
          SPLIT_OUT_HOST_AND_PATH,
          UPDATE_FROM_STAGING,
          INSERT_FROM_STAGING
        ].each do |statement|
          ActiveRecord::Base.connection.execute(statement)
        end
        $stderr.puts 'done.'
      end

      def self.from_redirector_mask!(filemask)
        Dir[File.expand_path(filemask)].each { |filename| Mappings.from_redirector_csv_file!(filename) }
      end
    end
  end
end
