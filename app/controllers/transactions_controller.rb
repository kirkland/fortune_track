class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end

  def new
    @transaction = Transaction.new
  end

  def create
#    render :text => params.inspect and return

    line_items_attrs = params[:transaction].delete(:line_items) if params[:transaction][:line_items].present?
    line_items_attrs ||= []

    @transaction = Transaction.new(params[:transaction])

    line_items_attrs.each do |line_item_attr|
       li = LineItem.new
       li.debit_in_cents = line_item_attr[:debit_in_cents].to_i
       li.credit_in_cents = line_item_attr[:credit_in_cents].to_i
       li.account_id = line_item_attr[:account_id].to_i
       @transaction.line_items << li
    end

    if @transaction.save
      flash[:message] = 'Transaction created.'
      redirect_to transactions_path
    else
      flash[:error] = 'Error in transaction create.'
      render :text => @transaction.errors.inspect and return
      render :new
    end
  end

  def update
    line_items_attrs = params[:transaction].delete(:line_items) || []
    @transaction = Transaction.find(params[:id])

    @transaction.update_attributes(params[:transaction])

    line_items_attrs.each do |line_item_attr|
      if line_item_attr[:id].present?
        li = LineItem.find(line_item_attr.delete :id)
      else
        li = @transaction.line_items.new
      end

      li.update_attributes(line_item_attr)
    end

    redirect_to edit_transaction_path(@transaction)
  end
end
