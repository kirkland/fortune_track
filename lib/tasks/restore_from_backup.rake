namespace :fortune_track do
  desc 'Restore development database from the production backup'
  task restore_from_backup: :environment do
    if Rails.env.development?
      RestoreFromBackup.new.restore
    else
      raise "Sorry, this will only run in development mode."
    end
  end
end
