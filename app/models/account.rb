class Account < ActiveRecord::Base
  PARSERS = ['CapitalOneParser', 'CentralBankParser', 'ChaseParser', 'IngDirectParser',
    'BankOfAmericaParser']

  attr_accessible :name, :parent_account, :parent_account_id, :parser_class, :sort_order

  belongs_to :parent_account, class_name: 'Account'
  has_many :child_accounts, class_name: 'Account', foreign_key: 'parent_account_id'
  has_many :line_items
  has_many :transactions, through: :line_items

  validate :no_parent_cycle

  before_save :update_related_full_names!
  before_save :update_sort_order
  after_save :update_global_sort_order

  default_scope order(:global_sort_order)

  def balance_type
    credit_total > debit_total ? :credit : :debit
  end

  def compact_children_sort_order
    index = 1
    child_accounts.order(:sort_order).each do |account|
      account.update_column :sort_order, index
      index += 1
    end
  end

  def credit_balance
    balance_type == :credit ? credit_total - debit_total : 0.to_money
  end

  def credit_balance_with_children
    credit_total_with_children > debit_total_with_children ? credit_total_with_children - debit_total_with_children : 0.to_money
  end

  def credit_total
    line_items.all.sum(&:credit).to_money
  end

  def credit_total_with_children
    credit_total + child_accounts.sum(&:credit_total_with_children).to_money
  end

  def debit_balance
    balance_type == :debit ? debit_total - credit_total : 0.to_money
  end

  def debit_balance_with_children
    debit_total_with_children > credit_total_with_children ? debit_total_with_children - credit_total_with_children : 0.to_money
  end

  def debit_total_with_children
    debit_total + child_accounts.sum(&:debit_total_with_children).to_money
  end

  def debit_total
    line_items.all.sum(&:debit).to_money
  end

  def depth
    parent_account_id.blank? ? 0 : 1 + parent_account.depth
  end

  def self.find_or_create_by_full_name(full_name)
    account = Account.find_by_full_name(full_name)
    return account if account.present?

    parts = full_name.split(':')
    name = parts.pop

    if parts.length == 0
      Account.create(name: name)
    else
      Account.create(name: name, parent_account: Account.find_or_create_by_full_name(parts.join(':')))
    end
  end

  def has_children?
    child_accounts.count > 0
  end

  def import_transactions
    return unless parser_class.present?

    p = "AccountParsers::#{parser_class}".constantize.new
    p.read_data_from_file # TODO: Should actually call download_data.
    transactions = p.parse_transactions

    new_transactions = transactions.reject do |transaction|
      Transaction.find_by_unique_code(transaction.unique_code)
    end

    new_transactions.each do |t|
      t.save!
    end
  end

  def self.net_worth
    Account.find_by_full_name('Assets').debit_balance_with_children -
      Account.find_by_full_name('Liabilities').debit_balance_with_children
  end

  def self.populate_sort_order
    Account.where(sort_order: nil).each do |account|
      sort_order = 1

      already_sorted = account.reload.siblings.where('sort_order IS NOT NULL')
      if already_sorted.present?
        sort_order = already_sorted.collect(&:sort_order).sort.last + 1
      end

      account.sort_order = sort_order
      account.save!
    end
  end

  def siblings
    new_record? ? siblings_with_self : siblings_with_self.where("id != ?", id)
  end

  def siblings_with_self
    if parent_account_id.nil?
      Account.where(parent_account_id: nil)
    else
      parent_account.child_accounts
    end
  end

  def descendents
    return [] if child_accounts.blank?

    rv = []
    child_accounts.sort_by { |x| x.sort_order.to_i }.collect do |child|
      rv << child
      rv << child.descendents
    end

    rv.flatten
  end

  def update_full_name
    if parent_account_id.present?
      self.full_name = "#{parent_account.full_name}:#{name}"
    else
      self.full_name = name
    end
  end

  def update_related_full_names!
    if name_changed?
      update_full_name

      child_accounts.each do |acct|
        acct.update_related_full_names!
        acct.save!
      end
    end
  end

  private

  def no_parent_cycle
    current = self

    while current = current.parent_account
      return true if current.nil?

      if current == self
        errors.add(:parent_account, 'cannot create a cycle in parent accounts')
      end
    end
  end

  def update_sort_order
    if new_record?

      self.sort_order = siblings.count + 1

    elsif sort_order_changed?

      moved_up = sort_order < sort_order_was.to_i

      # Use update_all to avoid after_save callbacks on other accounts.
      if moved_up
        siblings.where('sort_order >= ? AND sort_order < ?', sort_order, sort_order_was)
          .update_all('sort_order = sort_order + 1')
      else
        siblings.where('sort_order <= ? AND sort_order > ?', sort_order, sort_order_was)
          .update_all('sort_order = sort_order - 1')
      end

    elsif parent_account_id_changed?

      self.sort_order = siblings.count + 1

    end
  end

  def update_global_sort_order
    if sort_order_changed? || parent_account_id_changed?
      accounts = []

      Account.where(parent_account_id: nil).sort_by {|x| x.sort_order }.each do |account|
        accounts << account

        accounts += account.descendents
      end

      accounts.each_with_index do |account, index|
        account.update_column :global_sort_order, index + 1
      end
    end
  end
end
