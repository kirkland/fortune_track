class AccountImportsController < ApplicationController
  def new
    @parsers = AccountParsers::ALL
  end

  def create
    
  end
end
