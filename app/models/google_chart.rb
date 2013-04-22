class GoogleChart
  include DataMapper::Resource
  property :id, Serial
  property :chart_id, String, :length => 512
  property :data, Json

  def to_json
    {:key => self.chart_id, :data => self.data}.to_json
  end
end
