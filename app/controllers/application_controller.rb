class ApplicationController < ActionController::Base
  before_action :authenticate_with_balrog!

end
