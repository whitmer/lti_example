class LaunchRedirect
  include DataMapper::Resource
  property :id, Serial
  property :token, String, :length => 256
  property :url, String, :length => 1024
  property :created_at, Time
  property :last_launched_at, Time
  property :launches, Integer
end