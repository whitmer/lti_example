class CachedTweet
  include DataMapper::Resource
  property :id, Serial
  property :tweet_id, String, :length => 512
  property :data, Text
end