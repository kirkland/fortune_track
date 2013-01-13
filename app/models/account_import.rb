class AccountImport < ActiveRecord::Base
  # TODO: validation that importer_class_name is valid

  after_create :start_import

  private

  def start_import
    self.started_at = Time.zone.now
    save!

    importer = importer_class_name.constantize.new

    begin
      if data.present?
        importer.raw_data = data
        new_transactions = importer.create_new_transactions
      else
        new_transactions = importer.download_and_create_transactions
      end

      self.successful = true
    rescue => e
      self.successful = false
    end

    save!
  end
end
