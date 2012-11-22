class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all
  end

  def new
    @transaction = Transaction.new
  end

  def create
    render :text => params.inspect and return
    @transaction = Transaction.new(params[:transaction])

    if @transaction.save
      flash[:message] = 'Transaction created.'
      redirect_to transactions_path
    else
      flash[:error] = 'Error in transaction create.'
      render :new
    end
  end
end
