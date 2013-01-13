require 'csv'

module AccountImporters
  class BankOfAmericaImporter < GenericAccountImporter

    include BankAccount

    def primary_account
      @primary_account ||= Account.all.detect{|x| x.name =~ /Bank of America/}
    end

    def build_transactions(filename=nil)
      CSV.parse(@raw_data).each do |row|
        next if row.length < 4 || row[0] == 'Date' || row[1] =~ /Beginning balance/

        transaction = Transaction.new
        transaction.unique_code = row.join ','
        transaction.date = parse_date row[0]
        transaction.description = row[1]

        outflow = row[2].to_s.strip =~ /^-/

        amount = row[2].sub(/^-/, '').to_money

        if outflow
          asset = transaction.line_items.build
          asset.account = primary_account
          asset.credit = amount

          expense = transaction.line_items.build
          expense.account = debit_account
          expense.debit = amount
        else
          asset = transaction.line_items.build
          asset.account = primary_account
          asset.debit = amount

          income = transaction.line_items.build
          income.account = credit_account
          income.credit = amount
        end

        @transactions << transaction
      end

      @transactions
    end

    def download_data
      username = Credentials['bank_of_america']['username']
      password = Credentials['bank_of_america']['password']

      filename = File.join(Rails.root, 'tmp', 'stmt.csv')
      FileUtils.rm filename if File.exists? filename

      with_browser do |b|
        b.goto 'https://www.bankofamerica.com/'
        b.text_field(name: 'id').set username
        b.select(name: 'stateselect').select 'Massachusetts'
        b.input(id: 'top-button').click

        Watir::Wait.until { b.h2(text: 'Your SiteKey').exists? }
        b.text_field(type: 'password').set password
        b.span(text: 'Sign in').click

        b.a(id: 'PRIMARY').click

        b.a(text: 'Download').click

        b.label(for: 'transactionRange').click
        b.label(for: 'csv_format').click
        b.a(title: 'Download').click
      end

      @raw_data = File.read(filename)
    end

    private

    def default_data_filename
      File.join(Rails.root, 'notes/sample_data/bank_of_america.txt')
    end

  end
end