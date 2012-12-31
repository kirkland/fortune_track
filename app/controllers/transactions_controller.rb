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

  def show
    @transaction = Transaction.find(params[:id])
  end

  def create
    line_items_attributes = params[:transaction].delete(:line_items) || []
    new_line_items = []

    @transaction = Transaction.new(params[:transaction])

    line_items_attributes.each do |attr|
      attr.delete(:id)
      attr.delete(:deleted)
      new_line_items << @transaction.line_items.build(attr)
    end

    if @transaction.save
      redirect_to transaction_path(@transaction.id)
    else
      flash[:error] = @transaction.errors.inspect
      render :edit
    end
  end

  def update
    @transaction = Transaction.find(params[:id])

    line_items_attributes = params[:transaction].delete(:line_items) || []

    new_line_items = []

    ActiveRecord::Base.transaction do
      line_items_attributes.each do |attr|
        if attr[:id].present?
          li = @transaction.line_items.find(attr[:id])
          deleted = attr.delete(:deleted)
           if deleted.present?
            li.destroy
          else
            li.assign_attributes(attr)
            li.account_id = attr[:account_id]
            li.save!
          end
        else
          attr.delete(:id)
          attr.delete(:deleted)
          new_line_items << @transaction.line_items.create(attr)
        end
      end

      @transaction.update_attributes(params[:transaction])

      if !@transaction.valid?
        flash[:error] = @transaction.errors.inspect
        raise ActiveRecord::Rollback
      end
    end

    if @transaction.valid?
      redirect_to edit_transaction_path(@transaction)
    else
      # Magic. Necessary to 'undelete' attempted deletions.
      # For some reason, @transaction.line_items.reload doesn't do the trick.
      @transaction.line_items(true)
      @line_items = @transaction.line_items + new_line_items

      flash[:error] = @transaction.errors.inspect
      render :edit
    end
  end
end
