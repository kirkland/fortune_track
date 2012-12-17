def create_accounts(data, parent_account_id=nil)
  if data.is_a? String
    Account.create(name: data, parent_account_id: parent_account_id)
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
