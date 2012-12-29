Capistrano.configuration(:must_exist).load do
  desc 'Upload secret credentials file to server.'
  task :upload_credentials, role: :app do
    file = File.join File.dirname(__FILE__), '../config/credentials.yml'
    if File.exists? file
      upload file, '/u/apps/fortune_track/current/config/credentials.yml'
    else
      raise "No credentials file at #{file} found."
    end
  end
  after :deploy, 'upload_credentials'
end
