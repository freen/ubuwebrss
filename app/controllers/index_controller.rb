class IndexController < ApplicationController

	before_filter :set_scrape_log

	def index
		do_scrape
		@latest_entries = UbuEntry.limit(5).order('id desc')
	end

	private

		def set_scrape_log
			@log_last_scrape = ScrapeEvent.last
			@log_recent_scrapes_with_entries = ScrapeEvent.where('ubu_entries_count > 0').limit(5).order('id desc')
		end
end
