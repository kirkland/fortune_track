namespace :fortune_track do
  desc 'Run all automatic imports available'
  task run_imports: :environment do
    AccountImporters::ALL.each do |klazz|
      next if !klazz.download_capable
      ai = AccountImport.new
      ai.importer_class_name = klazz.to_s
      ai.save
    end
  end
end
