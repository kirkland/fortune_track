require File.join(Rails.root, '/test/factories')

def create_accounts(data, parent_account_id=nil)
  if data.is_a? String
    if !Account.find_by_name_and_parent_account_id(data, parent_account_id)
      Account.create(name: data, parent_account_id: parent_account_id)
    end
  else
    # I think each hash will only ever have one key/value pair.
    name = data.keys.first
    child_account_data = data.values.first
    account = Account.create(name: name, parent_account_id: parent_account_id)
    child_account_data.each { |x| create_accounts(x, account.id) }
  end
end

data = YAML.load(File.read(File.join(Rails.root, 'db/initial_accounts.yml')))
data.each { |x| create_accounts(x) }

# Probably don't need fake data anymore.
#if Rails.env.development?
#  # Some seed transaction data.
#  cash = Account.where(name: 'Cash').first
#  opening = Account.where(name: 'Opening Balance').first
#
#  t = FactoryGirl.build(:transaction)
#  t.line_items << FactoryGirl.build(:line_item, account: cash, debit: 1000.to_money)
#  t.line_items << FactoryGirl.build(:line_item, account: opening, credit: 1000.to_money)
#  t.save!
#
#  10.times { FactoryGirl.create(:cash_expense_transaction) }
#  5.times { FactoryGirl.create(:liability_expense_transaction) }
#  2.times { FactoryGirl.create(:income_transaction) }
#end
