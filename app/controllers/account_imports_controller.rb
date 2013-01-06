class AccountImportsController < ApplicationController
  def new
    @parsers = AccountParsers::ALL
  end

  def create
    importer_class = params[:importer_class].constantize

    if !AccountParsers::ALL.include? importer_class
      raise 'That is not an importer class, hacker.'
    end

    p = importer_class.new

    if params[:file].present?
      p.raw_data = params[:file].read
      new_transactions = p.create_new_transactions
    else
      new_transactions = p.download_and_create_transactions
    end

    flash[:notice] = "Added #{new_transactions.count} new transactions."

    redirect_to root_path
  end
end
