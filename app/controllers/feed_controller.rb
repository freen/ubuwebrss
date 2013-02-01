class FeedController < ApplicationController
	
	before_filter :set_sanitizer

	def entries_all
		do_scrape
	    @posts = UbuEntry.all(:order => "created_at DESC", :limit => 400) 
	    render :layout => false, :content_type => "application/rss+xml"
	end

	private

		def set_sanitizer
			@sanitizer = Sanitize.new(Sanitize::Config::BASIC)
		end

		def scheduled_scrape_is_due

			# How long since we last scraped?
			now = Time.new
			last_scrape = ScrapeEvent.last

			return true if last_scrape.nil?

			minutes_since_last_scrape = ((now - last_scrape.created_at) / 1.minute).round		
			scrape_interval_minutes = Setting::getIntegerValue('scrape_interval_minutes')
			return minutes_since_last_scrape >= scrape_interval_minutes
		end

		def do_scrape
			if scheduled_scrape_is_due

				scrape_event = ScrapeEvent.new

				# Scrape ubu.com!
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

				new_entries = 0

				# Process them in order of priority
				content_priorities.each do |type_constant, set_slug|

					# Was this content set successfully scraped?
					if content_sets.has_key? set_slug and content_sets[set_slug] != false

						content_set = content_sets[set_slug].reverse

						# Bulk lookup existing entries & collect their :href properties,
						# which are unique within each content_set
						existing_urls = []
						UbuEntry.where(["entry_type = ?", type_constant]).each do |entry|
							existing_urls << entry[:href]
						end

						# Process each scraped entry
						content_set.each do |entry|
							this_entry_exists = existing_urls.include? entry[:href]
							# Store it if it doesn't exist
							unless this_entry_exists
								entry_record = UbuEntry.new
								entry_record.scrape_event = scrape_event
								entry.each{ |key, value| entry_record[key] = value }
								entry_record[:entry_type] = type_constant
								entry_record.save
								new_entries += 1
							end
						end
					end

				end

				# If this scrape didn't result in any new UbuEntries, manually
				# save the ScrapeEvent model to make sure its logged.
				if new_entries == 0
					scrape_event.save
				end
			end
		end

end
