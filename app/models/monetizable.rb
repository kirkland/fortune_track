module Monetizable
  mattr_accessor :money_as_json_cache
  self.money_as_json_cache = {}

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def money(attr_name)
      amount_attr_name = "#{attr_name}_amount"
      currency_code_attr_name = "#{attr_name}_currency_code"

      composed_of attr_name,
        class_name: 'Money',
        mapping: [
          [amount_attr_name, 'cents'],
          [currency_code_attr_name, 'currency_as_string']
        ],
        constructor: Proc.new { |amount, currency_code|
          Money.new(amount || 0, currency_code || Money.default_currency)
        },
        converter: Proc.new { |value|
          if value.respond_to?(:to_money)
            value.to_money
          else
            raise ArgumentError, "Unable to convert #{value.class} to Money"
          end
        }

      before_validation Proc.new { |model|
        unless model[amount_attr_name]
          model.send "#{amount_attr_name}=", 0
        end

        unless model[currency_code_attr_name]
          model.send "#{currency_code_attr_name}=",
            Money.default_currency.iso_code
        end
      }, on: :create
    end

    def validates_money(attr_name, options = {})
      minimum = options[:greater_than_zero] ? 1 : 0

      validates_numericality_of "#{attr_name}_amount",
        greater_than_or_equal_to: minimum, only_integer: true

      validates_inclusion_of "#{attr_name}_currency_code",
        in: [Money.default_currency.iso_code]
    end
  end

  module InstanceMethods
    def money_as_json(money)
      Monetizable.money_as_json_cache[money.cents] ||= {
        amount: money.cents,
        currency_code: money.currency.iso_code,
        currency_symbol: money.currency.symbol,
        formatted_amount: money.format(symbol: false)
      }
    end
  end
end
