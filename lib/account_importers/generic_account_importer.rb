module AccountImporters
  class GenericAccountImporter
    attr_accessor :raw_data, :transactions

    def initialize
      @transactions = []
    end

    # Should return primary account for the file parsed, e.g. a bank account or
    # credit card account.
    def primary_account
      subclass_must_define
    end

    # When a transaction is created, if the primary_account has a credit balance,
    # then the account defined here will have a debit balance.
    def debit_account
      @debit_account ||= Account.find_by_full_name 'Expenses:Unknown'
    end

    # When a transaction is created, if the primary_account has a debit balance,
    # then the account defined here will have a credit balance.
    def credit_account
      subclass_must_define
    end

    # This method will translate @raw_data in to new transactions.
    # Either read_data_from_file or download_data must be called first.
    def build_transactions
      subclass_must_define
    end

    # This will save new transactions to the database, skipping over already-existing ones.
    def create_new_transactions
      new_transactions = build_transactions.reject do |transaction|
        Transaction.unscoped.find_by_unique_code(transaction.unique_code)
      end

      new_transactions.each do |t|
        t.save!
      end
    end

    # Download latest transaction data.
    def download_data
      subclass_must_define
    end

    # Read transactional data from a file (for development and testing, mainly).
    def read_data_from_file(filename=nil)
      filename = default_data_filename if filename.nil?
      @raw_data = File.read(filename)
    end

    def download_and_create_transactions
      download_data
      create_new_transactions
    end

    def read_and_create_transactions
      read_data_from_file
      create_new_transactions
    end

    def save_screenshot(browser)
      download_directory = File.join Rails.root, 'tmp'
      browser.screenshot.save File.join(download_directory,
        "#{Time.now.to_i}_#{self.class.name}.png")
    end

    private

    def subclass_must_define
      # TODO: can we find out what the name of the method is?
      raise "Subclass must define this method."
    end

    def parse_date(date_string)
      month, day, year = date_string.split('/').collect(&:to_i)
      Date.new year, month, day
    end

    def default_data_filename
      raise "Subclass must define this method."
    end

    def with_browser
      if !Rails.env.development?
        h = Headless.new
        h.start
      end

      download_directory = File.join Rails.root, 'tmp'
      profile = Selenium::WebDriver::Chrome::Profile.new
      profile['download.prompt_for_download'] = false
      profile['download.default_directory'] = download_directory

      b = Watir::Browser.new :chrome, profile: profile

      begin
        yield b
      rescue => e
        if Rails.env.development?
          binding.pry
        else
          save_screenshot b
          raise e
        end
      end

      b.close

      h.destroy if !Rails.env.development?
    end
  end
end
