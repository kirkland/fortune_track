module AccountParsers
  class CapitalOneParser < GenericAccountParser
    attr_accessor :raw_data, :transactions

    def initialize
      @transactions = []
    end

    def primary_account
      @primary_account ||= Account.all.detect{ |x| x.name =~ /Capital One/ }
    end

    def debit_account
      @debit_account ||= Account.find_or_create_by_full_name 'Expenses:Unknown'
    end

    def credit_account
      @credit_account ||= Account.find_or_create_by_full_name 'Assets:Unknown'
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
        unique_code = "#{date}:#{description}:#{category}:#{amount}"

        transaction = Transaction.new
        transaction.unique_code = unique_code
        transaction.date = date
        transaction.description = description

        debit = amount_string =~ /^\(.*\)$/ ? true : false

        if debit
          transaction.line_items.build(account: primary_account, debit: amount)
          transaction.line_items.build(account: credit_account, credit: amount)
        else
          transaction.line_items.build(account: primary_account, credit: amount)
          transaction.line_items.build(account: debit_account, debit: amount)
        end

        @transactions << transaction
      end

      @transactions
    end

    def read_data_from_file(filename=nil)
      filename = File.join(Rails.root, 'notes/sample_data/capital_one.html') if filename.nil?
      @raw_data = File.read(filename)
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

    private

    def parse_date(date_string)
      month, day, year = date_string.split('/')
      Date.parse("#{year}-#{month}-#{day}")
    end
  end
end