require 'csv'

module AccountParsers
  class IngDirectParser < GenericAccountParser

    include BankAccount

    # Since we get data for multiple ING accounts at once, we need to specify the account_id
    # in order to know which account to use.
    def primary_account(account_id)
      case account_id
        when '540524954' then Account.all.detect{|x| x.full_name =~ /ING Direct:Checking/ }
        when '123567907' then Account.all.detect{|x| x.full_name =~ /ING Direct:Savings/ }
        when '165003188' then Account.all.detect{|x| x.full_name =~ /ING Direct:Espresso/ }
      end
    end

    def build_transactions(filename=nil)
      CSV.parse(@raw_data).each do |row|
        next if row[0] == 'BANK ID' || row.blank?

        transaction = Transaction.new
        transaction.unique_code = row.join(',')
        transaction.date = Date.parse row[7]
        transaction.description = row[10]

        outflow = row[6] == 'DEBIT'

        amount = row[8].sub(/-/, '').to_money

        asset_account = primary_account(row[1])

        if outflow
          asset = transaction.line_items.build
          asset.account = asset_account
          asset.credit = amount

          expense = transaction.line_items.build
          expense.account = debit_account
          expense.debit = amount
        else
          asset = transaction.line_items.build
          asset.account = asset_account
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
      username = Credentials['ing_direct']['username']
      password = Credentials['ing_direct']['password']

      with_browser do |b|
        b.goto 'http://ingdirect.com'
        b.a(text: 'Sign In').click
        b.text_field(:id => 'ACNID').set username
        b.image(alt: 'Continue').click

        # Security questions.
        if b.div(:class => 'm_security_quest').exists?
          b.div(:class => 'm_security_quest').divs.each do |div|
            next unless div.label.exists?
            next if div.checkbox.exists?

            question = div.label.html
            answer = case question
                     when /your first job located/
                       Credentials['ing_direct']['first_job']
                     when /your father's mother/
                       Credentials['ing_direct']['fathers_mother']
                     when /your father's father/
                       Credentials['ing_direct']['fathers_father']
                     when /your mother's middle name/
                       Credentials['ing_direct']['mothers_middle']
                     when /father's middle name/
                       Credentials['ing_direct']['fathers_middle']
                     else
                       raise "I don't know the answer to '#{question}'"
                     end

            div.text_field.set answer
          end

          b.image(alt: 'Continue').click

          # PIN prompt.
          password.split('').each do |digit|
            b.img(src: "https://images.ingdirect.com/images/secure//nimbus/pinpad/#{digit}.gif")
              .click
          end
          b.img(alt: 'Continue').click

          # Account overview.
          b.a(text: 'Download').click

          # Download page. Downloads to file in tmp, though we don't know the name.
          b.input(value: 'CSV').click
          b.a(title: 'Download').click
        end
      end
    end

    private

    def default_data_filename
      File.join(Rails.root, 'notes/sample_data/ing_direct.csv')
    end

  end
end
