module AccountParsers
  class Transaction < Struct.new(:date, :description, :category, :amount, :unique_id)
  end
end
