Capistrano.configuration(:must_exist).load do
  desc 'Upload secret credentials file to server.'
  task :upload_credentials, role: :app do
    file = "#{ENV['HOME']}/.fortune_track_credentials.yml"
    if File.exists? file
      upload file, '/u/apps/fortune_track/current/config/credentials.yml'
    end
  end
end
