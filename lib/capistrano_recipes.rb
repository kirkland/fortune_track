Capistrano.configuration(:must_exist).load do
  desc 'Upload secret credentials file to server.'
  task :upload_credentials, role: :app do
    file = "#{ENV['HOME']}/.fortune_track_credentials.yml"
    if File.exists? file
      upload file, '/u/apps/fortune_track/current/config/credentials.yml'
    else
      puts 'Warning: no real credentials file found. Your app will be accessible with the default credentials.'
    end
  end
  after :deploy, 'upload_credentials'
end
