class FeedController < ApplicationController
  
  before_filter :set_rss_values

  # This controller must not use the layout

  def news
    do_scrape
      @posts = UbuEntry.all(:order => "id DESC", :limit => 400)
      render :layout => false, :content_type => Mime::RSS
  end

  private

    def set_rss_values
      last_scrape_with_entries = ScrapeEvent::get_last_with_entries

      last_build_date = nil
      unless last_scrape_with_entries.nil?
        last_build_date = last_scrape_with_entries.created_at.strftime '%a, %d %b %Y %H:%M:%S %p %Z'
      end

      @rss_values = {
        :last_build_date => last_build_date,
        :ttl => Setting::getIntegerValue('scrape_interval_minutes')
      }
    end

end
