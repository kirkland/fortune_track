class Account < ActiveRecord::Base
  attr_accessible :name, :parent_account_id

  belongs_to :parent_account, class_name: 'Account'

  def full_name
    if parent_account_id.present?
      "#{parent_account.full_name}:#{name}"
    else
      name
    end
  end
end
