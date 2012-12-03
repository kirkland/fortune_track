class Account < ActiveRecord::Base
  attr_accessible :name, :parent_account_id

  belongs_to :parent_account, class_name: 'Account'
  has_many :line_items

  def update_full_name
    if parent_account_id.present?
      "#{parent_account.full_name}:#{name}"
    else
      name
    end
  end

  def self.find_or_create_with_hierarchy(full_name)
    parts = full_name.split(':')
  end
end
