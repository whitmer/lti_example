require 'sinatra/base'

module Sinatra
  module OEmbed
    def self.registered(app)
      app.get "/oembed" do
        url = params['url']
        code = params['code'] || CGI.unescape(url.split(/code=/)[1])
        {
          'version' => '1.0',
          'type'    => 'rich',
          'html'    => code,
          'width'   => 600,
          'height'  => 400
        }.to_json
      end    

      app.get "/oembed_render" do
        html = "<html><body>"
        endpoint = params[:endpoint]
        url = params[:url]
        uri = URI.parse(endpoint + (endpoint.match(/\?/) ? '&url=' : '?url=') + CGI.escape(url) + '&format=json')
        res = Net::HTTP.get(uri) rescue "{}"
        data = JSON.parse(res) rescue {}
        if data['type']
          if data['type'] == 'photo' && data['url'] && data['url'].match(/^http/)
            html += "<img src='#{data['url']}' alt='#{data['title']}'/>"
          elsif data['type'] == 'link' && data['url'] && data['url'].match(/^(http|https|mailto)/)
            html += "<a href='#{data['url']}'>#{data['title']}</a>"
          elsif data['type'] == 'video' || data['type'] == 'rich'
            html += data['html']
          end
        else
          html += "<p>There was a problem retrieving this resource. The external tool provided invalid information about the resource.</p>"
        end
        html += "</body></html>"
        html
      end
      
    end
  end
  
  register OEmbed
end