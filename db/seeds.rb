# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

expenses = Account.create(name: 'Expenses')

assets = Account.create(name: 'Assets')
current = Account.create(name: 'Current', parent_account_id: assets.id)
Account.create(name: 'Cash', parent_account_id: current.id)

equity = Account.create(name: 'Equity')
Account.create(name: 'Opening Balance', parent_account_id: equity.id)

income = Account.create(name: 'Income')
Account.create(name: 'Salary', parent_account_id: income.id)

liabilities = Account.create(name: 'Liabilities')
Account.create(name: 'Credit Cards', parent_account_id: liabilities.id)
