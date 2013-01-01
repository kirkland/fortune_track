class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all

    if params[:account_id].present?
      @transactions = Account.find(params[:account_id]).transactions
    end
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end

  def new
    @transaction = Transaction.new

    currency = Account.all.detect { |x| x.name =~ /Currency/ }
    expense = Account.all.detect { |x| x.full_name =~ /^Expenses:Other$/ }

    # Default to a cash expense.
    @transaction.line_items.build(account: currency)
    @transaction.line_items.build(account: expense)
  end

  def new_cash
    @transaction = Transaction.new

    @debit_choices = Account.all.select { |x| x.full_name =~ /^Expenses/ }
    @debit_account = Account.find_by_full_name 'Expenses:Other'
  end

  def create_cash
    @transaction = Transaction.new(params[:transaction])
    amount = params[:amount].to_money
    @transaction.line_items.build(debit: amount, account_id: params[:debit_account])
    @transaction.line_items.build(credit: amount, account: Account.find_by_name('Currency'))

    if @transaction.save
      redirect_to transaction_path(@transaction)
    else
      flash[:error] = @transaction.errors.inspect
      render :edit
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def create
    line_items_attributes = params[:transaction].delete(:line_items) || []

    @transaction = Transaction.new(params[:transaction])

    line_items_attributes.each do |attr|
      attr.delete(:id)
      attr.delete(:deleted)
      @transaction.line_items.build(attr)
    end

    if @transaction.save
      redirect_to transaction_path(@transaction.id)
    else
      flash[:error] = @transaction.errors.inspect
      render :edit
    end
  end

  def update
    line_items_attributes = params[:transaction].delete(:line_items) || []

    @transaction = Transaction.find(params[:id])

    line_items_attributes.each do |attr|
      if attr[:id].present?

        li = @transaction.line_items.detect{|x| x.id == attr[:id].to_i}

        if attr.delete(:deleted).present?
          li.mark_for_destruction
        else
          li.assign_attributes(attr)
        end

      else
        attr.delete(:id)
        attr.delete(:deleted)
        @transaction.line_items.build(attr)
      end
    end

    @transaction.assign_attributes(params[:transaction])

    # This is for view: in case the save fails, keep our attempted changes.
    @line_items = @transaction.line_items.clone

    if @transaction.save
      redirect_to transaction_path(@transaction.id)
    else
      flash[:error] = @transaction.errors.inspect
      render :edit
    end
  end
end
