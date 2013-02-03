class ApplicationController < ActionController::Base
  protect_from_forgery

	before_filter :set_hostname

	private
		def set_hostname
			@hostname = request.env["REQUEST_URI"]
		end	
end
