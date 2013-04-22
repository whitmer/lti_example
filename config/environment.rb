ENV['RACK_ENV'] ||= 'development'
ENV['APPLICATION_ROOT'] ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))

$:.unshift ENV['APPLICATION_ROOT']

require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'].to_sym)

require 'find'

load_paths = %w{config/initializers app}
load_paths.each do |path|
  Find.find("#{ENV['APPLICATION_ROOT']}/#{path}") { |f|
    require f if f.match(/\.rb$/)
  }
end

DataMapper.finalize
DataMapper.auto_upgrade!
