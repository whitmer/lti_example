require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'dm-types'

env = ENV['RACK_ENV'] || settings.environment
DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{ENV['APPLICATION_ROOT']}/#{env}.sqlite3"))
