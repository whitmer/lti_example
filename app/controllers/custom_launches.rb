require 'sinatra/base'
require 'digest/md5'

module Sinatra
  module CustomLaunches
    def self.registered(app)
      app.post "/titanpad" do
        return "invalid parameters" unless params['context_id'] && params['resource_link_id']
        str = "#{params['context_id']}-#{params['resource_link_id']}"
        redirect to("http://titanpad.com/lti-" + Digest::MD5.hexdigest(str) + "?fullScreen=1&displayName=#{CGI.escape(params['lis_person_name_full'] || '')}")
      end
      
      app.post "/speeqe" do
        return "invalid parameters" unless params['context_id'] && params['resource_link_id']
        str = Digest::MD5.hexdigest("#{params['context_id']}-#{params['resource_link_id']}")[0, 20]
        redirect to("http://#{str}.speeqe.com")
      end
      
      app.get "/speeqe" do
        redirect to("http://lti-demo.speeqe.com")
      end
      
      app.get "/dropbox_key" do
        @@dropbox_config = ExternalConfig.first(:config_type => 'dropbox')
        return "Dropbox not propertly configured" unless @@dropbox_config
        {:key => @@dropbox_config.value}.to_json
      end
      
      app.post "/google_chart" do
        if session[params[:key]]
          params[:data] = JSON.parse(params[:data]) if params[:data].is_a?(String)
          chart = GoogleChart.first_or_new(:chart_id => params[:key])
          chart.data = params[:data]
          chart.save!
          chart.to_json
        else
          nil.to_json
        end
      end
      
      app.get "/google_chart" do
        chart = GoogleChart.first(:chart_id => params[:key])
        chart.to_json
      end
      
      app.get "/data_stream" do
        uri = URI.parse("https://api.quizlet.com/2.0/search/sets")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.ssl?
        tmp_url = uri.path + "?" + uri.query
        request = Net::HTTP::Get.new(tmp_url)
        response = http.request(request)
      end
    end
  end 
  register CustomLaunches
end