require 'sinatra/base'

class EduApps < Sinatra::Base
  if defined?(RACK_ENV)
    set :environment, RACK_ENV
  end

  register Sinatra::Main
  register Sinatra::ExternalSearch
  register Sinatra::Apps
  register Sinatra::Admin
  register Sinatra::TwitterLogin
  register Sinatra::Assessment
  register Sinatra::CustomLaunches
  register Sinatra::ConfigXML
  register Sinatra::OEmbed
  
  # sinatra wants to set x-frame-options by default, disable it
  disable :protection
  enable :sessions
  # set session key in heroku with: heroku config:add SESSION_KEY=a_longish_secret_key
  raise "session key required" if ENV['RACK_ENV'] == 'production' && !ENV['SESSION_KEY']
  set :session_secret, ENV['SESSION_KEY'] || "local_secret"
  set :method_override, true
end