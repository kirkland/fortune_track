class RestoreFromBackup
  def restore
    DatabaseDownloader.new.download
    `bundle exec rake db:reset &&
      psql fortune_track_development < /tmp/fortune_track_production.sql`
  end

  class DatabaseDownloader
    def initialize
      @connection = Fog::Storage.new({
        :provider                 => 'AWS',
        :aws_access_key_id        => Credentials[:aws][:key],
        :aws_secret_access_key    => Credentials[:aws][:secret]
      })
    end

    def download
      download_from_s3
      extract_database
    end

    private

    def bucket
      @connection.directories.get bucket_name
    end

    def bucket_name
      'robmk-database-backups'
    end

    def most_recent_object
      bucket.files.sort_by(&:key).last
    end

    def download_from_s3
      delete_old_downloads

      file = File.open(database_download_filename, 'wb')
      file.write most_recent_object.body
      file.close
    end

    def database_download_filename
      File.join '/tmp', 'ft_database.tar'
    end

    def delete_old_downloads
      if File.exists?(database_download_filename)
        File.delete database_download_filename
      end

      if File.exists?(database_extraction_dirname)
        FileUtils.rm_rf database_extraction_dirname
      end
    end

    def database_extraction_dirname
      File.join '/tmp', 'fortune_track'
    end

    def extract_database
      untar_downloaded_data
      move_database
      gunzip_database
    end

    def untar_downloaded_data
      `cd /tmp && tar xvf #{database_download_filename}`
    end

    def move_database
      `mv #{database_extraction_dirname}/databases/PostgreSQL/fortune_track_production.sql.gz /tmp`
    end

    def gunzip_database
      `cd /tmp && gunzip -f fortune_track_production.sql.gz`
    end
  end
end
