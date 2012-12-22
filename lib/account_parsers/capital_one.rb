module AccountParsers
  class CapitalOne
    attr_accessor :raw_data, :transactions

    def initialize
      @transactions = []
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

        payment = amount_string =~ /^\(.*\)$/ ? true : false

        # Note: Only dedupe when we're comparing against previously persisted transactions.
        # If we're looking at the web page, we can assume no transactions are mistakenly
        # listed twice.
        unique_code = "#{date}:#{description}:#{category}:#{amount}"

        transaction = Transaction.new
        transaction.unique_code = unique_code
        transaction.date = date
        transaction.description = description

        if payment
          liability = transaction.line_items.build
          liability.account = Account.all.detect{|x| x.full_name =~ /Liabilities:.*Capital One/}
          liability.debit = amount

          # We don't know where the payment came from (and it might even be income if it's a reward!),
          # so it will be up to the user to categorize this.
          asset = transaction.line_items.build
          asset.account = Account.find_by_full_name 'Assets:Unknown'
          asset.credit = amount
        else
          liability = transaction.line_items.build
          liability.account = Account.all.detect{|x| x.full_name =~ /Liabilities:.*Capital One/}
          liability.credit = amount

          expense = transaction.line_items.build
          expense.account = Account.all.detect{|x| x.full_name =~ /^Expenses:.*Uncategorized/}
          expense.debit = amount
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
