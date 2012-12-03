module AccountParsers
  class Transaction < Struct.new(:date, :description, :category, :amount, :unique_id); end

  class CapitalOne
    attr_accessor :transactions

    def initialize
      @transactions = []
    end

    def get_transactions
      @transactions = []

      credentials = YAML.load(File.open('./credentials.yml'))
      username = credentials['username']
      password = credentials['password']

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
    end

    private

    def parse_date(date_string)
      month, day, year = date_string.split('/')
      Time.parse("#{year}-#{month}-#{day}")
    end

  end
end
