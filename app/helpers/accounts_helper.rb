module AccountsHelper
  def indent(account)
    "#{account.depth * 20}px"
  end

  def show_children?(account)
    account.depth < 1
  end
end
