class Account < ActiveRecord::Base
  attr_accessible :name, :parent_account_id

  belongs_to :parent_account, class_name: 'Account'
  has_many :child_accounts, class_name: 'Account', foreign_key: 'parent_account_id'
  has_many :line_items

  before_save :update_related_full_names!

  def credit_balance
    line_items.all.sum(&:credit)
  end

  def debit_balance
    line_items.all.sum(&:debit)
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
