require "net/http"

class OpenGraphScrapperJob < ApplicationJob
  queue_as :default

  def perform(tweet_id:)
    tweet = find_tweet(tweet_id)

    extract_urls(tweet).each do |url|
      body = fetch_content(url)
      og_data = extract_og_data(body)
      create_resource_description(tweet, og_data)
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

    {
      url: doc.xpath('//meta[@property="og:url"]').first["content"],
      title: doc.xpath('//meta[@property="og:title"]').first["content"],
      image: doc.xpath('//meta[@property="og:image"]').first["content"],
      description: doc.xpath('//meta[@property="og:description"]').first["content"]
    }
  end

  def create_resource_description(tweet, og_data)
    ResourceDescription.new(
      tweet: tweet,
      url: og_data[:url],
      title: og_data[:title],
      description: og_data[:description],
      image: Image.new(
        url: og_data[:image],
        byte_size: 42
      )
    ).save!
  end
end
