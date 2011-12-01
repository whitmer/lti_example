RACK_ENV='test'
require 'rspec'
require 'rack/test'
require 'json'
require './lti_example'

RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end

def populate_apps
  apps = JSON.parse(File.read('./public/data/lti_examples.json'))
  ap = AdminPermission.create(:username => "me", :apps => "any")
  apps.each_with_index do |app, idx|
    obj = App.build_or_update(app['id'], app, ap)
  end
end
  
def app_review
  app = App.last
  @review = AppReview.create(
    :tool_id => app.tool_id,
    :tool_name => app.name,
    :user_name => "Some User",
    :user_url => "http://www.example.com/some_user",
    :rating => 4,
    :comments => "This is good",
    :created_at => Time.now
  )
end

def admin_permission
  AdminPermission.create
end