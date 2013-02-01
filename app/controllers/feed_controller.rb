class FeedController < ApplicationController
	def index
		_do_scrape
	end

	def entriesAll
		_do_scrape
	    @posts = UbuEntry.all(:order => "created_at DESC", :limit => 400) 
	    render :layout => false, :content_type => "application/rss+xml"
	end

	private
	def _do_scrape
		scheduled_scrape_is_due = false
		# scheduled_scrape_is_due = true
		if scheduled_scrape_is_due
			parser = UbuParse.new
			content_sets = parser.extract
			# UbuEntry type constants double as order priority, lowest first.
			content_priorities = {
				UbuEntry::TYPE_COLLECTION => :collection_announcements,
				UbuEntry::TYPE_NEW_ADDITION => :new_additions,
				UbuEntry::TYPE_RECENT_ADDITION => :recent_additions
			}
			# Order the content set slugs by their priority weight, in reverse
			# (such that the most important entries appear as being more recent)
			content_priorities = content_priorities.sort_by{ |key, value| key }
			# Process them in order of priority
			content_priorities.each do |type_constant, set_slug|
				# If there wasn't an error scraping:
				if content_sets.has_key? set_slug and content_sets[set_slug] != false
					# Bulk lookup of existing entries
					existing_urls = []
					UbuEntry.where(["entry_type = ?", type_constant]).each do |entry|
						existing_urls << entry[:href]
					end
					content_set = content_sets[set_slug].reverse
					# Process each scraped entry
					content_set.each do |entry|
						thisEntryExists = existing_urls.include? entry[:href]
						# Store it if it doesn't exist
						unless thisEntryExists
							entry_record = UbuEntry.new
							entry.each{ |key, value| entry_record[key] = value }
							entry_record[:entry_type] = type_constant
							entry_record.save
						end
					end
				end
			end
		end
	end
end
