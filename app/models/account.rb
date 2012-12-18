class Account < ActiveRecord::Base
  attr_accessible :name, :parent_account_id

  belongs_to :parent_account, class_name: 'Account'
  has_many :child_accounts, class_name: 'Account', foreign_key: 'parent_account_id'
  has_many :line_items

  before_save :update_related_full_names!

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
end
