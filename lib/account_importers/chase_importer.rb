require 'csv'

module AccountImporters
  class ChaseImporter < GenericAccountImporter

    include CreditCardAccount

    def download_capable
      true
    end

    def primary_account
      @primary_account ||= Account.all.detect{|x| x.name =~ /Amazon/}
    end

    def build_transactions(filename=nil)
      CSV.parse(@raw_data).each do |row|
        next if row[0] == 'Type'

        transaction = Transaction.new
        transaction.unique_code = row.join(' - ')
        transaction.date = parse_date row[1]
        transaction.description = row[3]

        outflow = row[0] == 'Sale'

        amount = row[4].to_s.strip.sub(/-/, '').to_money

        if outflow
          liability = transaction.line_items.build
          liability.account = primary_account
          liability.credit = amount

          expense = transaction.line_items.build
          expense.account = debit_account
          expense.debit = amount
        else
          liability = transaction.line_items.build
          liability.account = primary_account
          liability.debit = amount

          asset = transaction.line_items.build
          asset.account = credit_account
          asset.credit = amount
        end

        @transactions << transaction
      end

      @transactions
    end

    def download_data
      username = Credentials['chase']['username']
      password = Credentials['chase']['password']

      filename = File.join(Rails.root, 'tmp', 'Activity.CSV')
      FileUtils.rm filename if File.exists? filename

      with_browser do |b|
        b.goto 'https://chaseonline.chase.com/logon.aspx'
        b.text_field(name: 'UserID').set username
        b.text_field(name: 'Password').set password

        b.input(id: 'logon').click
        Watir::Wait.until { b.table(:class => 'greeting').exists? }

        b.goto 'https://cards.chase.com/cc/Account/Activity/175322547'
        Watir::Wait.until { b.select(id: 'StatementPeriodQuick').exists? }

        b.select(id: 'StatementPeriodQuick').select('All Transactions')

        b.a(text: 'Download').click
        Watir::Wait.until { b.a(id: 'DownloadCsv').visible? }

        b.a(id: 'DownloadCsv').click
      end

      @raw_data = File.read(filename)
    end

    private

    def default_data_filename
      File.join(Rails.root, 'notes/sample_data/chase_amazon.csv')
    end

  end
end
