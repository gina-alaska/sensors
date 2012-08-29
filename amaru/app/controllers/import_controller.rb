class ImportController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def csv
    rest = RestImport.new(params["slug"], params["data"])

    if rest.import
      render :text => "success", status: 200
    else
      render :text => "error", status: 500
    end
  end
end