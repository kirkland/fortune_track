module AccountParsers
  class CapitalOne
    attr_accessor :transactions

    def initialize
      @transactions = []
    end

    def get_transactions
      @transactions = []

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

      @n = Nokogiri::HTML(@b.html)
      @rows = @n.css('tr.trxSummayRow')

      @rows.each do |row|
        tds = row.css('td').to_a

        date = parse_date(tds[0].content.strip)
        description = tds[1].content.strip
        category = tds[2].content.strip
        amount = tds[3].content.strip.sub(/\$/, '').to_money

        # Note: Only dedupe when we're comparing against previously persisted transactions.
        # If we're looking at the web page, we can assume no transactions are mistakenly
        # listed twice.
        unique_id = "#{date}:#{description}:#{category}:#{amount}"

        @transactions << Transaction.new(date, description, category, amount, unique_id)
      end

      @b.close

      @transactions
    end

    def build_transaction(transaction)
      t = ::Transaction.new
      t.description = transaction.description
      t.date = transaction.date

      capital_one = Account.find_or_create_with_hierarchy 'Liabilities:Credit Card:Capital One'
      unknown_asset = Account.find_or_create_with_hierarchy 'Asset:Unknown'
      uncategorized_expense = Account.find_or_create_with_hierarchy 'Expense:Uncategorized'

      amount = transaction.amount.cents
      if transaction.category == 'Payment'
        t.line_items.build(debit_in_cents: amount, account: capital_one)
        t.line_items.build(credit_in_cents: amount, account: unknown_asset)
      else
        t.line_items.build(debit_in_cents: amount, account: uncategorized_expense)
        t.line_items.build(credit_in_cents: amount, account: capital_one)
      end
    end

    private

    def parse_date(date_string)
      month, day, year = date_string.split('/')
      Date.parse("#{year}-#{month}-#{day}")
    end

  end
end
