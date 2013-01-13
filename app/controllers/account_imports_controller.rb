class AccountImportsController < ApplicationController
  def new
    @parsers = AccountImporters::ALL
  end

  def create
    account_import = AccountImport.new
    account_import.importer_class_name = params[:importer_class]

    # TODO: Move to model validation.
    if !AccountImporters::ALL.include? account_import.importer_class_name.constantize
      raise 'That is not an importer class, hacker.'
    end

    if params[:file].present?
      account_import.data = params[:file].read
    end

    if account_import.save
      flash[:notice] = "New transactions on the way!"
    else
      flash[:error] = account_import.errors.inspect
    end

    redirect_to root_path
  end
end
