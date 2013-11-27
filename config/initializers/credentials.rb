Credentials = YAML.load(File.open(File.join(Rails.root, 'config', 'credentials.yml')).read).
  with_indifferent_access
