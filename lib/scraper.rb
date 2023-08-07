require "httparty"
require "cgi"
require "json"
require "nokogiri"
require "open-uri"

class Scraper

  def get_data
    response = HTTParty.get("https://www.google.com/search?q=Van+Gogh+paintings&gl=us&hl=en&ei=PIjNZOv8LtCGxc8PqpqZyAQ&ved=0ahUKEwjrisXgksSAAxVQQ_EDHSpNBkkQ4dUDCBE&uact=5&oq=Van+Gogh+paintings&gs_lp=Egxnd3Mtd2l6LXNlcnAiElZhbiBHb2doIHBhaW50aW5nczIPEAAYigUYsQMYQxhGGPsBMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAESJARUIYPWIYPcAJ4AJABAJgBwAGgAcABqgEDMC4xuAEDyAEA-AEBwgILEAAYigUYhgMYsAPiAwQYASBBiAYBkAYF&sclient=gws-wiz-serp", {
      headers: {"User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.19582"},
      debug_output: STDOUT
    })

    nokogiri_response = Nokogiri::HTML(response.body)

    artworks = nokogiri_response.css(".BVG0Nb")
    # e.g., "The Mating Season1949"

    image_thumbnails = image_thumbnails_from(nokogiri_response)

    artworks_array = artworks.each_with_index.map do |artwork, index|
      {
        name: artwork.css(".s3v9rd").text,
        extensions: [artwork.css(".tAd8D").text],
        link: "https://www.google.com" + artwork["href"],
        image: image_thumbnails[index]
      }
    end

    data = {
      artworks: artworks_array
    }

    data.to_json
  end

  private

  def image_thumbnails_from(nokogiri_response)
    scripts = nokogiri_response.css("script")

    scripts.map do |script|
      match = script.children.text.match(/data:image\/jpeg;base64,\/[^;]*/)
      match ? match[0] : nil
    end
  end
end
