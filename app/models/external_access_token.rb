class ExternalAccessToken
  include DataMapper::Resource
  property :id, Serial
  property :token, String, :length => 256
  property :name, String
  property :site_url, String, :length => 1024
  property :active, Boolean
end