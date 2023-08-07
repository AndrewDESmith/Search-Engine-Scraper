require "spec_helper"
require "./lib/scraper"
require "date"

describe "Knowledge Graph for Claude Monet Paintings" do
  before :all do
    scraper = Scraper.new
    @response = JSON.parse(scraper.get_data)
  end

  it "return an 'artworks' key with an array value" do
    expect(@response["artworks"].is_a?(Array)).to be true
  end

  describe "artwork" do
    it "return array cells with 'name', 'extensions', 'link', and 'image' keys" do
      desired_keys = ["extensions", "image", "link", "name"]
      artworks_keys = @response["artworks"].sample.keys.sort
      expect(artworks_keys).to eql(desired_keys)
    end
  end

  it "return 'name' in string format" do
    name = @response["artworks"].sample["name"]
    expect(name).to be_a(String)
    expect(name).to_not be_empty
  end

  describe "extensions" do
    it "return an array of strings" do
      extensions = @response["artworks"].sample["extensions"]
      expect(extensions).to be_a(Array)
      expect(extensions.sample).to be_a(String)
    end

    it "return valid date string in year format, or an empty string" do
      date_string = @response["artworks"].sample["extensions"].first

      date_object = begin
        Date.strptime(date_string, "%Y")
      rescue Date::Error => e
      end

      pp "date_string"
      pp date_string

      pp "date_object"
      pp date_object

      if !date_object.nil?
        expect(date_object).to be_a(Date)
      else
        binding.pry if !date_string.empty?
        expect(date_string).to be_empty
      end
    end
  end

  describe "link" do
    it "return as a valid Google link" do
      link = @response["artworks"].sample["link"]
      expect(link).to be_a(String)
      expect(link.include?("https://www.google.com")).to be true
    end

    # Seems like a good idea, but names do not always match up with their queries.
    xit "return with query param matching the name" do
      pending "May not be a valid test."
      artwork = @response["artworks"].sample
      link = artwork["link"]
      name = artwork["name"]
      name.gsub!(" ", "+")
      name.gsub!("...", "")

      # Some non-English characters are sometimes encountered in the names. The query strings would need to be converted to test name inclusion in the link.
      # %C3%B6
      # \xC3\xB6".force_encoding("UTF-8")
      # "ö"

      expect(link.include?("q=#{name}")).to be true
    end
  end

  describe "image" do
    xit "return in valid JPEG format" do
      pending "Not yet implemented."
      # image = @reponse["artworks"].sample
    end
  end
end
