require "net/http"

class OpenGraphScrapperJob < ApplicationJob
  OG_PROPERTIES = %i[url title image description].freeze

  queue_as :default

  def perform(tweet_id:)
    tweet = find_tweet(tweet_id)

    extract_urls(tweet).each do |url|
      og_data = extract_og_data(fetch_content(url))
      # a page without complete Open Graph metadata simply has no resource to describe
      next if og_data.values.any?(&:blank?)

      create_resource_description(tweet, og_data)
    rescue StandardError => e
      # ponytail: one bad URL shouldn't drop the rest of the tweet's resources
      logger.warn("#{self.class}: #{url} failed: #{e.message}")
    end
  end

  private

  def find_tweet(id)
    Tweet.find(id)
  end

  def extract_urls(tweet)
    URI.extract(tweet.content, %w[http https])
  end

  def fetch_content(url)
    Net::HTTP.get(URI.parse(url))
  end

  def extract_og_data(body)
    doc = Nokogiri::HTML(body)

    OG_PROPERTIES.index_with do |property|
      doc.at_xpath("//meta[@property='og:#{property}']")&.[]("content")
    end
  end

  def byte_size(url)
    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |http| http.head(uri.request_uri) }

    response["content-length"]&.to_i || Net::HTTP.get(uri).bytesize
  end

  def create_resource_description(tweet, og_data)
    ResourceDescription.create!(
      tweet: tweet,
      url: og_data[:url],
      title: og_data[:title],
      description: og_data[:description],
      image: Image.new(
        url: og_data[:image],
        byte_size: byte_size(og_data[:image])
      )
    )
  end
end
