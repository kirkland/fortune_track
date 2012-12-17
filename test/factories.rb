FactoryGirl.define do
  factory :transaction do
    description Faker::Lorem.words(3).join(' ').capitalize + '.'
    date { (Time.now - rand(10).days).to_date }

    after :build do |t|
      amount = rand(1000)
      li1 = build(:line_item, transaction: t, debit_in_cents: amount)
      li2 = build(:line_item, transaction: t, credit_in_cents: amount)

      t.line_items << li1
      t.line_items << li2
    end
  end

  factory :line_item, aliases: [:debit_line_item] do
    account Account.first
  end
end
