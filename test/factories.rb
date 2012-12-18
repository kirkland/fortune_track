require 'factory_girl'

FactoryGirl.define do
  factory :transaction do
    description Faker::Lorem.words(3).join(' ').capitalize + '.'
    date { (Time.now - rand(10).days).to_date }

    factory :asset_expense_transaction do
      after :build do |t|
        amount = rand(1000)
        li1 = build(:expense_line_item, transaction: t, debit_in_cents: amount)
        li2 = build(:asset_line_item, transaction: t, credit_in_cents: amount)

        t.line_items << li1
        t.line_items << li2
      end
    end

    factory :liability_expense_transaction do
      after :build do |t|
        amount = rand(1000)
        li1 = build(:expense_line_item, transaction: t, debit_in_cents: amount)
        li2 = build(:liability_line_item, transaction: t, credit_in_cents: amount)

        t.line_items << li1
        t.line_items << li2
      end
    end

    factory :income_transaction do
      after :build do |t|
        amount = rand(1000)
        li1 = build(:asset_line_item, transaction: t, debit_in_cents: amount)
        li2 = build(:income_line_item, transaction: t, credit_in_cents: amount)

        t.line_items << li1
        t.line_items << li2
      end
    end
  end

  factory :line_item do
    account { Account.all.sample }

    factory :expense_line_item do
      account { Account.all.select{|x| x.full_name =~ /^Expense/}.sample }
    end

    factory :asset_line_item do
      account { Account.all.select{|x| x.full_name =~ /^Asset/}.sample }
    end

    factory :liability_line_item do
      account { Account.all.select{|x| x.full_name =~ /^Liabilities/}.sample }
    end

    factory :income_line_item do
      account { Account.all.select{|x| x.full_name =~ /^Income/}.sample }
    end

    factory :equity_line_item do
      account { Account.all.select{|x| x.full_name =~ /^Equity/}.sample }
    end
  end
end
