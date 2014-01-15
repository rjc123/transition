module Transition
  module Import
    class Hits
      # Bouncer/Redirector paths that should be ignored when importing hits
      # These appear when a 404/410 page is rendered which includes assets
      # served by the app.
      #
      # Lines should probably never be removed from this, only added.
      BOUNCER_PATHS = [
        '/robots.txt',
        '/sitemap.xml',
        '/favicon.ico',
        '/gone.css',
        '/ie.css',
        '/bis_crest_13px_x2.png',
        '/bis_crest_18px_x2.png',
        '/businesslink-logo-2x.png',
        '/directgov-logo-2x.png',
        '/govuk-crest.png',
        '/govuk-logo.gif',
        '/govuk-logo.png',
        '/ho_crest_13px_x2.png',
        '/ho_crest_18px_x2.png',
        '/mod_crest_13px_x2.png',
        '/mod_crest_18px_x2.png',
        '/org_crest_13px_x2.png',
        '/org_crest_18px_x2.png',
        '/so_crest_13px_x2.png',
        '/so_crest_18px_x2.png',
        '/wales_crest_13px_x2.png',
        '/wales_crest_18px_x2.png',
      ]

      TRUNCATE = <<-mySQL
        TRUNCATE hits_staging
      mySQL

      LOAD_DATA = <<-mySQL
        LOAD DATA LOCAL INFILE $filename$
        INTO TABLE
          hits_staging
        FIELDS TERMINATED BY '\t'
        LINES TERMINATED BY '\\n'
        IGNORE 1 LINES
          (hit_on, count, http_status, hostname, path)
      mySQL

      INSERT_INTO_HITS = <<-mySQL
        INSERT IGNORE INTO hits (host_id, path, path_hash, http_status, `count`, hit_on)
        SELECT h.id, st.path, SHA1(st.path), st.http_status, st.count, st.hit_on
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname
        WHERE  st.count >= 10
        AND    st.path NOT IN (#{BOUNCER_PATHS.map { |path| "'" + path + "'" }.join(', ')})
      mySQL

      INSERT_INTO_URLS = <<-mySQL
        INSERT IGNORE INTO urls (host_id, path, path_hash)
        SELECT h.id, st.path, SHA1(st.path)
        FROM   hits_staging st
        INNER JOIN hosts h on h.hostname = st.hostname
        WHERE  st.count >= 10
        AND    st.path NOT IN (#{BOUNCER_PATHS.map { |path| "'" + path + "'" }.join(', ')})
      mySQL

      RELATE_URLS_AND_HITS = <<-mySQL
        UPDATE hits
        SET hits.url_id = (
          SELECT urls.id FROM urls
          WHERE  urls.host_id = hits.host_id
          AND    urls.path_hash = hits.path_hash
        )
      mySQL

      def self.from_redirector_tsv_file!(filename)
        # TODO maybe do inserts/updates in a transaction? see line 98 first
        $stderr.print "Importing #{filename} ... "
        [
          TRUNCATE,
          LOAD_DATA.sub('$filename$', "'#{File.expand_path(filename)}'"),
          INSERT_INTO_URLS,
          INSERT_INTO_HITS,
          RELATE_URLS_AND_HITS
        ].flatten.each do |statement|
          ActiveRecord::Base.connection.execute(statement)
        end
        # Hits.foo
        $stderr.puts 'done.'
      end

      def self.foo
        URL.where('mapping_id is null').each do |url|
          canonical_path = url.host.site.canonical_path(url.path)
          canonical_path_hash = Digest::SHA1.hexdigest(canonical_path)
          mapping_id = Mapping.where(path_hash: canonical_path_hash).pluck(:id).first
          url.update_column(:mapping_id, mapping_id)
        end
      end

      def self.from_redirector_mask!(filemask)
        done = 0
        ActiveRecord::Base.connection.execute('SET autocommit=0')
        begin
          Dir[File.expand_path(filemask)].each do |filename|
            Hits.from_redirector_tsv_file!(filename)
            done += 1
          end
          ActiveRecord::Base.connection.execute('COMMIT')
        ensure
          ActiveRecord::Base.connection.execute('SET autocommit=1')
        end

        $stderr.puts "#{done} hits files imported."
      end
    end
  end
end
