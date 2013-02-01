xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "UbuWeb"
    xml.description "UbuWeb is a completely independent resource dedicated to all strains of the avant-garde, ethnopoetics, and outsider arts."
    xml.link 'http://www.ubu.com'

    for post in @posts
      xml.item do
        xml.title post.title
        xml.description post.description
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link post.href
        xml.guid post.href
      end
    end
  end
end