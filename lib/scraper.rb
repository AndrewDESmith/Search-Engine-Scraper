require "net/http"
require "cgi"
# require "ap"
# require "json"
require "pry"
require "nokogiri"
require "open-uri"

class Scraper
  __ENCODING__

  def get_data
    uri = URI.parse("https://raw.githubusercontent.com/serpapi/code-challenge/master/files/van-gogh-paintings.html")
    response = Net::HTTP.get(uri)
    # binding.pry
    # response.force_encoding("ISO-8859-1").encode("UTF-8")
    # response.force_encoding("UTF-8")

    # binding.pry
    # server_encoding = "ISO-8859-1"
    # response = response.force_encoding(server_encoding).encode("UTF-8")
    parsed_response = CGI.parse(response)

    # doc = Nokogiri::HTML(URI.open('https://raw.githubusercontent.com/serpapi/code-challenge/master/files/van-gogh-paintings.html'))

    Pry::ColorPrinter.pp(parsed_response)

    klitem = nokogiri_doc.css(".klitem")
    thumbnails = painting_thumbnails_from(parsed_response)

    returned_data = klitem.each_with_index.map do |item, index|
      [{
        artworks: {
          name: name_from(item),
          extensions: [extensions_date_from(item)],
          link: google_link_from(item),
          image: thumbnails[index]
        }
      }]
    end

    Pry::ColorPrinter.pp(returned_data)
    # binding.pry
  end

  private

  def nokogiri_doc
    @doc ||= Nokogiri::HTML(URI.open('https://raw.githubusercontent.com/serpapi/code-challenge/master/files/van-gogh-paintings.html'))
  end

  def google_link_from(klitem)
    klitem.attributes["href"].value  # Example Google link to individual painting title's search results.
  end

  def name_from(klitem)
    name = klitem.attributes["title"].value # Example painting name (Starry Night)
    binding.pry if name.match(/Starry Night Over The Rh.+/)
    name.split("(")[0].strip
  end

  def extensions_date_from(klitem)
    klitem.attributes["title"].value.match(/(\d+)/).to_s  # Date of painting from name.
  end

  def painting_thumbnails_from(parsed_response)
    # item.size > 60 ==> Other short base64 images are present, besides the thumbnails.
    @thumbnails ||= parsed_response.keys.select { |item| item.match(/base64.+/) && item.size > 60 }
  end
end

scraper = Scraper.new
scraper.get_data
