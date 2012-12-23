module AccountParsers
  class CapitalOne < GenericAccountParser
    attr_accessor :raw_data, :transactions

    def initialize
      @transactions = []
    end

    def primary_account
      @primary_account ||= Account.all.detect{ |x| x.name =~ /Capital One/ }
    end

    # If the primary_account gets debited, what account should be credited?
    def debit_secondary_account
      @debit_secondary_account ||= Account.find_or_create_by_full_name 'Assets:Unknown'
    end

    def credit_secondary_account
      @credit_secondary_account ||= Account.find_or_create_by_full_name 'Expenses:Unknown'
    end

    def download_data
      username = Credentials['capital_one']['username']
      password = Credentials['capital_one']['password']

      @b = Watir::Browser.new :chrome

      @b.goto 'https://servicing.capitalone.com/C1/Login.aspx'
      @iframe=@b.frame(id: 'loginframe')
      @iframe.text_field(name: 'user').set username
      @iframe.text_field(name: 'password').set password
      @iframe.button(id: 'cofisso_btn_login').click

      @b.link(text: 'Visa Signature').click

      @b.select(name: 'ddlQuickView').select('Last 90 Days')

      @raw_data = @b.html

      @b.close

      @raw_data
    end

    def parse_transactions
      raise 'You must download data or read from a file before parsing it.' if @raw_data.blank?

      @n = Nokogiri::HTML @raw_data

      @rows = @n.css('tr.trxSummayRow')

      @rows.each do |row|
        tds = row.css('td').to_a

        date = parse_date(tds[0].content.strip)
        description = tds[1].content.strip
        category = tds[2].content.strip
        amount_string = tds[3].content.strip.sub(/\$/, '')
        amount = amount_string.to_money

        debit = amount_string =~ /^\(.*\)$/ ? true : false

        # Note: Only dedupe when we're comparing against previously persisted transactions.
        # If we're looking at the web page, we can assume no transactions are mistakenly
        # listed twice.
        unique_code = "#{date}:#{description}:#{category}:#{amount}"

        transaction = Transaction.new
        transaction.unique_code = unique_code
        transaction.date = date
        transaction.description = description

        debit_line_item = transaction.line_items.build
        credit_line_item = transaction.line_items.build

        if debit
          debit_line_item.account = primary_account
          debit_line_item.debit = amount

          credit_line_item.account = debit_secondary_account
          credit_line_item.credit = amount
        else
          credit_line_item.account = primary_account
          credit_line_item.credit = amount

          debit_line_item.account = credit_secondary_account
          debit_line_item.debit = amount
        end

        @transactions << transaction
      end

      @transactions
    end

    def read_data_from_file(filename=nil)
      filename = File.join(Rails.root, 'notes/sample_data/capital_one.html') if filename.nil?
      @raw_data = File.read(filename)
    end

    private

    def parse_date(date_string)
      month, day, year = date_string.split('/')
      Date.parse("#{year}-#{month}-#{day}")
    end
  end
end
