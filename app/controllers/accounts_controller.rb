class AccountsController < ApplicationController
  def index
    @accounts = ['Assets', 'Liability', 'Equity'].collect do |full_name|
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
    @transactions = @account.transactions
    if params[:start_date].present?
      @transactions = @transactions.where('date >= ?', params[:start_date])
    end
    if params[:end_date].present?
      @transactions = @transactions.where('date <= ?', params[:end_date])
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
end
