class AccountsController < ApplicationController
  def index
    @accounts = ['Assets', 'Liabilities', 'Equity'].collect do |full_name|
      Account.find_by_full_name full_name
    end

    @show_all = params[:show_all].present?
  end

  def new
    @account = Account.new
  end

  def edit
    @account = Account.find(params[:id])
  end

  def create
    @account = Account.new(params[:account])

    if @account.save
      redirect_to accounts_path, notice: 'Account was successfully created.'
    else
      render action: "new"
    end
  end

  def show
    @account = Account.find(params[:id])

    if params[:near_transaction_id]
      apply_near_condition
    else
      @transactions = @account.transactions
      apply_date_filters
    end
  end

  def update
    @account = Account.find(params[:id])

    if @account.update_attributes(params[:account])
      redirect_to accounts_path, notice: 'Account was successfully updated.'
    else
      render action: "edit"
    end
  end

  private

  def apply_date_filters
    if params[:start_date]
      @transactions = @transactions.where('date >= ?', params[:start_date])
    end

    if params[:end_date]
      @transactions = @transactions.where('date <= ?', params[:end_date])
    end
  end

  # Given a transaction ID, show a page with it in the middle, and roughly 10 above and below it.
  def apply_near_condition
    @focused_transaction = Transaction.find(params[:near_transaction_id])

    more_recent_transactions = @account.transactions.
      where('date >= ?', @focused_transaction.date).
      order('date ASC').limit(10)

    less_recent_transactions = @account.transactions.
      where('date <= ?', @focused_transaction.date).
      order('date DESC').limit(10)

    @transactions = ([@focused_transaction] + more_recent_transactions +
      less_recent_transactions).sort_by(&:date).reverse.uniq
  end
end
