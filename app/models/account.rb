class Account < ActiveRecord::Base
  attr_accessible :name, :parent_account_id

  belongs_to :parent_account, class_name: 'Account'
  has_many :line_items

  def full_name
    if parent_account_id.present?
      "#{parent_account.full_name}:#{name}"
    else
      name
    end
  end
end
