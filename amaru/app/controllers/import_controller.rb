class ImportController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :require_login

  def csv
    rest = RestImport.new(params["slug"], params["token"], params["data"])

    if rest.import
      render :text => "success", status: 200
    else
      render :text => "error", status: 500
    end
  end
end