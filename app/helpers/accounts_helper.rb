module AccountsHelper
  def indent(account)
    "#{account.depth * 20}px"
  end
end
