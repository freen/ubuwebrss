class IndexController < ApplicationController

	before_filter :set_scrape_log

	def index
		do_scrape
		# abort 
	end

	private

		def set_scrape_log
			@scrape_log = ScrapeEvent.limit(10).order('id desc')
		end
end
