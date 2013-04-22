class AppReview
  include DataMapper::Resource
  property :id, Serial
  property :tool_id, String
  property :tool_name, String
  property :user_name, String
  property :user_url, String, :length => 1024
  property :user_avatar_url, String, :length => 1024
  property :user_id, String
  property :external_access_token_id, Integer
  property :created_at, Time
  property :rating, Integer
  property :comments, Text, :lazy => false

  belongs_to :external_access_token

  def source_name
    external_access_token.name
  end

  def source_url
    external_access_token.site_url
  end
end