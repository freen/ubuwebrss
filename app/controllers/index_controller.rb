class IndexController < ApplicationController

  before_filter :set_scrape_log

  def index
    do_scrape
    @latest_entries = UbuEntry.limit(7).order('id desc')
  end

  private

    def set_scrape_log
      @log_last_scrape = ScrapeEvent.last
      @log_recent_scrapes_with_entries = ScrapeEvent::get_last_with_entries
    end
end
