require 'rss'
require 'open-uri'

Jekyll::Hooks.register :site, :after_init do |site|
  begin
    rss_url = 'https://medium.com/feed/@srelan1'
    feed = RSS::Parser.parse(URI.open(rss_url).read)
    
    File.write('_data/posts_data.yml', {
    'posts' => feed.items.map { |item| 
      content = Nokogiri::HTML(item.content_encoded || item.description)

      image = content.css('img').first
      image_url = image ? image['src'] : nil
      image&.remove if image
      clean_text = content.text.strip
      {
        'title' => item.title,
        'link' => item.link,
        'date' => item.pubDate,
        'author' => item.dc_creator,
        'tags' => item.categories&.map(&:content),
        'image' => image_url,
        'excerpt' => clean_text.slice(0, 200)
      }
    }
    }.to_yaml)
  rescue => e
    puts "RSS Error: #{e.message}"
  end
end