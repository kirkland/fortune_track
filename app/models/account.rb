class Account < ActiveRecord::Base
  PARSERS = [AccountParsers::CapitalOne]

  attr_accessible :name, :parent_account_id, :parser_class, :sort_order

  belongs_to :parent_account, class_name: 'Account'
  has_many :child_accounts, class_name: 'Account', foreign_key: 'parent_account_id'
  has_many :line_items

  validate :no_parent_cycle

  before_save :update_related_full_names!
  before_save :update_siblings_sort_order

  def balance_type
    credit_total > debit_total ? :credit : :debit
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

  def self.find_or_create_with_hierarchy(full_name)
    parts = full_name.split(':')
  end

  def has_children?
    child_accounts.count > 0
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
    siblings_with_self.where("id != ?", id)
  end

  def siblings_with_self
    if parent_account_id.nil?
      Account.where(parent_account_id: nil)
    else
      parent_account.child_accounts
    end
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

  def compact_children_sort_order
    index = 1
    child_accounts.order(:sort_order).each do |account|
      account.sort_order = index
      account.save!
      index += 1
    end
  end

  def no_parent_cycle
    current = self

    while current = current.parent_account
      return true if current.nil?

      if current == self
        errors.add(:parent_account, 'cannot create a cycle in parent accounts')
      end
    end
  end

  def update_siblings_sort_order
    if sort_order_changed?
      moved_up = sort_order < sort_order_was

      if moved_up
        siblings.where('sort_order >= ? AND sort_order < ?', sort_order, sort_order_was).each do |account|
          account.sort_order = account.sort_order + 1
          account.save!
        end
      else
        siblings.where('sort_order <= ? AND sort_order > ?', sort_order, sort_order_was).each do |account|
          account.sort_order = account.sort_order - 1
          account.save!
        end
      end
    elsif parent_account_id_changed?
      self.sort_order = siblings.count + 1

      # Make sure old parent hierarchy stays in a consistent state.
      Account.find(parent_account_was).compact_children_sort_order
    end
  end
end
