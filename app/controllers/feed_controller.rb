class FeedController < ApplicationController
	
	# This controller must not use the layout

	def news
		do_scrape
	    @posts = UbuEntry.all(:order => "created_at DESC", :limit => 400)
	    render :layout => false, :content_type => Mime::RSS
	end

end
