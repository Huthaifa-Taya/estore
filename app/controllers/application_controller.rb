class ApplicationController < ActionController::Base
  # protect_from_forgery
  include Authentication
  include NavBar
  include CsvImporter

end
