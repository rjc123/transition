module Transition
  module Import
    class Hits
      TRUNCATE = <<-postgreSQL
        TRUNCATE hits_staging
      postgreSQL

      LOAD_DATA = <<-postgreSQLTemplate
        COPY hits_staging (date, count, status, host, path)
        FROM '$filename$'
        WITH DELIMITER AS '\t' CSV HEADER
      postgreSQLTemplate

      INSERT_FROM_STAGING = <<-postgreSQL
        INSERT INTO hits (host_id, path, path_hash, http_status, count, hit_on)
        SELECT h.id, st.path, encode(digest(st.path, 'sha1'), 'hex'), st.status, st.count, st.date
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.host
        WHERE
          st.count >= 10
          AND NOT EXISTS (
            SELECT 1 FROM hits
            WHERE path_hash = encode(digest(st.path, 'sha1'), 'hex') AND
                  host_id = h.id AND
                  http_status = st.status AND
                  hit_on = st.date
          )
      postgreSQL

      def self.from_redirector_tsv_file!(filename)
        $stderr.print "Importing #{filename} ... "
        [
          TRUNCATE,
          LOAD_DATA.sub('$filename$', File.expand_path(filename)),
          INSERT_FROM_STAGING
        ].flatten.each do |statement|
          ActiveRecord::Base.connection.execute(statement)
        end
        $stderr.puts 'done.'
      end

      def self.from_redirector_mask!(filemask)
        done = 0
        Dir[File.expand_path(filemask)].each do |filename|
          Hits.from_redirector_tsv_file!(filename)
          done += 1
        end

        $stderr.puts "#{done} hits files imported."
      end
    end
  end
end
