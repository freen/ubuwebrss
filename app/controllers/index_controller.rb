class IndexController < ApplicationController
	def index
		do_scrape
		# abort 
	end
end
