class AccountsController < ApplicationController
  def index
    @accounts = Account.where(parent_account_id: nil)
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

  def update
    @account = Account.find(params[:id])

    if @account.update_attributes(params[:account])
      redirect_to accounts_path, notice: 'Account was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to accounts_url }
      format.json { head :no_content }
    end
  end
end
