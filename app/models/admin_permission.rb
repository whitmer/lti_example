class AdminPermission
  include DataMapper::Resource
  property :id, Serial
  property :username, String, :length => 256
  property :apps, String, :length => 1024

  def self.allow_access(tool_id, username)
    ap = AdminPermission.first_or_new(:username => username)
    if ap.apps == 'any'
    elsif ap.apps
      ap.apps = (ap.apps + "," + tool_id).split(/,/).uniq.join(',')
    else
      ap.apps = tool_id
    end
    ap.save
    ap
  end

  def full_admin?
    allowed_access?
  end

  def allowed_access?(tool_id='any')
    if tool_id != 'any'
      self.apps == 'any' || self.apps.split(/,/).include?(tool_id)
    else
      self.apps == 'any'
    end
  end

  def as_json
    {
      :id => self.id,
      :username => self.username,
      :apps => self.apps
    }
  end
  def to_json
    as_json.to_json
  end
end