xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
  xml.channel do
    xml.title "UbuWeb"
    xml.description "UbuWeb is a completely independent resource dedicated to all strains of the avant-garde, ethnopoetics, and outsider arts."
    xml.link 'http://www.ubu.com'

    for post in @posts
      xml.item do
        xml.title post.title

        artist = post.artist.to_s
        unless artist.empty?
          # Manually add description for custom HTML sanitizing
          xml << " " * 6
          xml << "<dc:creator>" + @sanitizer_full.clean(artist) + "</dc:creator>\n"
        end
        
        description = post.description.to_s
        unless description.empty?
          # Manually add description for custom HTML sanitizing
          description = @sanitizer_basic.clean(description)
          xml << " " * 6
          xml << "<description><![CDATA[" + description + "]]></description>\n"
        end

        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link post.href
        xml.guid post.href
      end
    end
  end
end