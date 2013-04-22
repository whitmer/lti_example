class AppFilter
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :code, String, :length => 1024
  property :settings, Json

  def update_settings(params)
    self.settings = {}
    self.code ||= Digest::MD5.hexdigest(self.username + Time.now.to_i.to_s + rand(9999).to_s)
    self.settings['app_ids'] = {}
    self.settings['allow_new'] = params['allow_new'] == true || params['allow_new'] == '1'
    App.load_apps.each do |app|
      self.settings['app_ids'][app['id']] = false
    end
    (params['app_ids'] || []).each do |id|
      self.settings['app_ids'][id] = true
    end
    self.save
  end

  def as_json
    res = self.settings || {}
    res['code'] = self.code
    res
  end

  def to_json
    as_json.to_json
  end
end