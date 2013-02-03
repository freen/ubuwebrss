class FeedController < ApplicationController
	
	before_filter :set_sanitizer

	def entries_all
		do_scrape
	    @posts = UbuEntry.all(:order => "created_at DESC", :limit => 400)
	    render :layout => false, :content_type => Mime::RSS
	end

	private

		def set_sanitizer
			sanitize_config = Sanitize::Config::BASIC
			# No need for nofollow
			sanitize_config[:add_attributes]["a"].delete('rel')
			@sanitizer = Sanitize.new(sanitize_config)
		end

end
