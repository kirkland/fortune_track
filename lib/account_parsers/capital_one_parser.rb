module AccountParsers
  class CapitalOneParser < GenericAccountParser

    include CreditCardAccount

    def primary_account
      @primary_account ||= Account.all.detect{ |x| x.name =~ /Capital One/ }
    end


    def build_transactions
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

    def download_data
      username = Credentials['capital_one']['username']
      password = Credentials['capital_one']['password']

      with_browser do |b|
        @b = b

        @b.goto 'https://servicing.capitalone.com/C1/Login.aspx'
        @iframe=@b.frame(id: 'loginframe')
        @iframe.text_field(name: 'user').set username
        @iframe.text_field(name: 'password').set password
        @iframe.button(id: 'cofisso_btn_login').click

        if @b.form(id: 'validateMFAAuthAnswers').exists?
          question = @b.td(:class => 'MFA_Alignment').html
          answer = case question
                   when /your father's father/
                     Credentials['capital_one']['fathers_father']
                   when /high school/
                     Credentials['capital_one']['high_school']
                   when /born/
                     Credentials['capital_one']['born']
                   else
                     raise "I don't know the answer to 'k!"
                   end

           @b.text_field(name: 'txtAnswer1').value = answer
           @b.input(id: 'update').click
        end

        @b.link(text: 'Visa Signature').click

        @b.select(name: 'ddlQuickView').select('Last 90 Days')

        @raw_data = @b.html
      end

      @raw_data
    end

    private

    def default_data_filename
      File.join(Rails.root, 'notes/sample_data/capital_one.html')
    end

  end
end
