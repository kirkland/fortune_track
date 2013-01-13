class AccountImport < ActiveRecord::Base
  # TODO: validation that importer_class_name is valid

  OUTDATED_THRESHOLD = 2.days

  after_create :start_import

  scope :successful, where(successful: true)
  scope :recent, order('started_at DESC')

  def self.outdated
    outdated = {}

    AccountImporters::ALL.each do |importer_class_name|
      recent = AccountImport.successful.recent.where(importer_class_name: importer_class_name)
        .try(:first)
      if recent.nil? || recent.started_at < Time.now - OUTDATED_THRESHOLD
        outdated[importer_class_name] = recent.try(:started_at)
      end
    end

    outdated
  end

  private

  def start_import
    self.started_at = Time.now
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
