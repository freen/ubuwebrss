class IndexController < ApplicationController

	before_filter :set_scrape_log

	def index
		do_scrape
		@latest_entries = UbuEntry.limit(5).order('id desc')
	end

	private

		def set_scrape_log
			@scrape_log = ScrapeEvent.limit(5).order('id desc')
		end
end
