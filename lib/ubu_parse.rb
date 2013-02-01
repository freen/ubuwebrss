require 'uri'
require 'open-uri'
require 'nokogiri'

class UbuParse

	# NOTE ON PARSING STRATEGY:
	#
	# The markup used on UbuWeb's index page is fully unsemantic, and the
    # sections almost fully lack designating attributes, such as classes or ids.
	# Sections within general container elements are furthermore not divided
	# by sub nodes, but by line breaks and bold headers.
	#
	# Therefore the only way to parse the data is to anticipate their position by
	# <table> column sequence, and then by parsing their contents via the
	# position of expected headers.
	#
	# The parsing code is explained by comments since the xpath queries are
	# more or less uninstructive.

	def initialize
		@document_uri = 'http://www.ubu.com'
		@doc = ''
		@extracted_sets = {}
		@extracted_urls = []
	end

	# Returns a list of all "paths", organized by entry type, within which
	# they're effectively (not schematically) unique identifiers.
	def getAllURLs
		# Don't duplicate effort
		unless @extracted_urls.empty?
			return @extracted_urls
		end

		urls = {
			:collection_announcements => [],
			:recent_additions => [],
			:new_additions => []
		}

		content_sets = extract()
		content_sets.each do |slug, set|
			set.each do |entry|
				urls[slug] << entry[:href]
			end
		end

		@extracted_urls = urls
		return urls
	end

	def extract
		# Don't duplicate effort
		unless @extracted_sets.empty?
			return @extracted_sets
		end

		@doc = Nokogiri::HTML( open( @document_uri ) )
		
		# False means a parsing error occurred. This translates to the code's
		# understanding of the document as well: we expect the data to be
		# there, and if it isn't, we assume there was a parsing error.
		content_sets = Hash.new(false);

		# Key: column index, Value: metadata
		additions_column_metadata = {
			0 => { :slug => :recent_additions , :header_xpath => "b[text()='Recent Additions:']" },
			2 => { :slug => :new_additions , :header_xpath => "font/b[text()='New Additions:']" },
		}

		# The three columns of real data are indicated by the 'default' class
		columns = @doc.xpath( "//td[@class='default']" ).each_with_index do |column, index|

			# Process the outer "~ Additions" columns, defined in
			# additions_column_metadata
			if additions_column_metadata.has_key? index
				slug = additions_column_metadata[index][:slug]
				header_xpath = additions_column_metadata[index][:header_xpath]
				content_sets[slug] = extract_addition_entries( column , header_xpath )

			# Process center column uniquely
			elsif index == 1
				content_sets[:collection_announcements] = extract_collection_entries( column )
			end

		end

		@extracted_sets = content_sets
		return content_sets
	end

	private

		def normalize_href( href )
			uri = URI( href )
			uri.scheme = 'http' if uri.scheme.nil?
			uri.host = 'www.ubu.com' if uri.host.nil?
			uri.path = uri.path[1 .. uri.path.length] if uri.path.index("./") == 0
			return uri.to_s
		end

		def extract_addition_item_after_image( image_node )
			anchor_node = image_node.next
			# Fail if the subsequent node is not an <a>
			return false if anchor_node.name != 'a'
			entry = {
				:artist => '',
				:title => '',
				:href => normalize_href( anchor_node[:href] )
			}
			anchor_node.children.each do |child|
				case child.name
				when 'text'
					entry[:artist] << child.inner_text + ' '
				when 'font'
					entry[:title] << child.children.first.inner_text + ' '
				end
			end
			# Trim leading and trailing whitespace from all values
			entry.each{ |key, value| entry[key] = value.strip }
			return entry
		end

		# Given a header node, loops through subsequent tags in search of <img>
		# tags, which as bullets designate each item.
		def extract_addition_items_after_heading( header_node )
			items = []
			next_node = header_node
			while 1
				next_node = next_node.next
				break if next_node.nil?
				case next_node.name
				when 'b'
					return false
				when 'br'
					next
				when 'img'
					item = extract_addition_item_after_image( next_node )
					items << item unless item == false
				end
			end
			return items
		end

		# Used to recursively extract the entries in the center column of UbuWeb's
		# main page, dubbed the "Collection Entries"
		def extract_recursive_collection_entries( font_node )
			collection_entries = []
			entry_template = { :title => '', :description => '', :href => ''}
			# Identify the entry title by an <a> tag within a <b> tag
			font_node.children.each do |child_node|
				case child_node.name
				when 'b'
					title_anchor = child_node.child
					if title_anchor and title_anchor.name == 'a'
						# Put together the new entry
						entry = entry_template.clone
						entry[:title] = title_anchor.inner_text.strip
						entry[:href] = normalize_href( title_anchor[:href] )
						# Prep the description
						entry_copy = font_node.clone
						entry_copy.xpath('b').first.remove
						entry_copy.xpath('font').remove
						entry[:description] = entry_copy.inner_html.strip
						# Append it
						collection_entries << entry
					end
				when 'font'
					# Recurse into the next entry				
					collection_entries += extract_recursive_collection_entries( child_node )
				end
			end
			return collection_entries
		end

		# FOR OUTERMOST COLUMNS:
		# Given a td.default node, identifies the header with the given text and
		# passes this to the item extractor. (Presently, no wrapping node exists
		# in UbuWeb's markup.)
		def extract_addition_entries( column_node , header_xpath)
			heading = column_node.xpath( header_xpath ).first
			return false if heading.nil?
			return extract_addition_items_after_heading( heading )
		end

		# FOR CENTER COLUMN:
		# Given the center td.default node, descend into the recursively nested
		# entries. Entry titles and descriptions are designated by title's bold
		# link.
		def extract_collection_entries( column_node )
			column_node.children.each do |child_node|
				# Font tag designates the beginning of an entry
				if child_node.name == 'font'
					return extract_recursive_collection_entries( child_node )
				end
			end
			return false
		end
end