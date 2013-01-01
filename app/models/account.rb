class Account < ActiveRecord::Base
  include Monetizable

  attr_accessible :name, :parent_account, :parent_account_id, :sort_order

  belongs_to :parent_account, class_name: 'Account'
  has_many :child_accounts, class_name: 'Account', foreign_key: 'parent_account_id'
  has_many :line_items
  has_many :transactions, through: :line_items

  validate :no_parent_cycle

  before_save :update_related_full_names!
  before_save :update_sort_order
  after_save :update_global_sort_order

  default_scope order(:global_sort_order)

  money :debit_total
  money :credit_total

  # Basic balances.

  def calculate_debit_total
    self.debit_total = line_items.all.sum(&:debit).to_money
  end

  def calculate_credit_total
    self.credit_total = line_items.all.sum(&:credit).to_money
  end

  def update_balances!
    calculate_debit_total
    calculate_credit_total
    save!
  end

  def balance_type
    credit_total > debit_total ? :credit : :debit
  end

  def credit_balance
    balance_type == :credit ? credit_total - debit_total : 0.to_money
  end

  def debit_balance
    balance_type == :debit ? debit_total - credit_total : 0.to_money
  end

  # Family balances.

  def family_debit_total
    debit_total + child_accounts.sum(&:family_debit_total).to_money
  end

  def family_credit_total
    credit_total + child_accounts.sum(&:family_credit_total).to_money
  end

  def family_balance_type
    family_credit_total > family_debit_total ? :credit : :debit
  end

  def family_debit_balance
    family_debit_total > family_credit_total ? family_debit_total - family_credit_total : 0.to_money
  end

  def family_credit_balance
    family_credit_total > family_debit_total ? family_credit_total - family_debit_total : 0.to_money
  end

  def compact_children_sort_order
    index = 1
    child_accounts.order(:sort_order).each do |account|
      account.update_column :sort_order, index
      index += 1
    end
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

  def self.net_worth
    Account.find_by_full_name('Assets').family_debit_balance -
      Account.find_by_full_name('Liabilities').family_debit_balance
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
