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
    account = Account.find_by_name_and_parent_account_id(name, parent_account_id)
    if !account
      account = Account.create(name: name, parent_account_id: parent_account_id)
    end
    child_account_data.each { |x| create_accounts(x, account.id) }
  end
end

data = YAML.load(File.read(File.join(Rails.root, 'db/initial_accounts.yml')))
data.each { |x| create_accounts(x) }

if Rails.env.development?
  ['CapitalOneImporter', 'BankOfAmericaImporter', 'ChaseImporter', 'IngDirectImporter',
    'CentralBankImporter'].each do |class_name|
    "AccountImporters::#{class_name}".constantize.new.read_and_create_transactions
  end
end
