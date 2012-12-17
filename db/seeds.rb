# Assets
assets = Account.create(name: 'Assets')
current = Account.create(name: 'Current', parent_account_id: assets.id)
Account.create(name: 'Cash', parent_account_id: current.id)

# Equity
equity = Account.create(name: 'Equity')
Account.create(name: 'Opening Balance', parent_account_id: equity.id)

# Expenses
expenses = Account.create(name: 'Expenses')
food = Account.create(name: 'Food', parent_account_id: expenses.id)
Account.create(name: 'Restaurant', parent_account_id: food.id)
Account.create(name: 'Groceries', parent_account_id: food.id)

# Income
income = Account.create(name: 'Income')
Account.create(name: 'Salary', parent_account_id: income.id)

# Liabilities
liabilities = Account.create(name: 'Liabilities')
Account.create(name: 'Credit Cards', parent_account_id: liabilities.id)
