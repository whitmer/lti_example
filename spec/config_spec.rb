require File.dirname(__FILE__) + '/spec_helper'

describe 'Config Redirects' do
  include Rack::Test::Methods
  
  def app
    EduApps
  end
  
  describe "remote XML parser" do
    it "should fail on timeout" do
      Net::HTTP.any_instance.should_receive(:request).and_raise(Timeout::Error.new("too long!"))#return(OpenStruct.new(:code => "200", :body => "")
      get "/process_xml?url=http://www.example.com"
      last_response.should_not be_ok
      JSON.parse(last_response.body)['error'].should == "Request timed out"
    end
    
    it "should fail on redirect" do
      Net::HTTP.any_instance.should_receive(:request).and_return(OpenStruct.new(:code => "300", :body => ""))
      get "/process_xml?url=http://www.example.com"
      last_response.should_not be_ok
      JSON.parse(last_response.body)['error'].should == "Parser doesn't handle redirects"
    end
    
    it "should fail if parameters aren't found" do
      Net::HTTP.any_instance.should_receive(:request).and_return(OpenStruct.new(:code => "200", :body => "{}"))
      get "/process_xml?url=http://www.example.com"
      last_response.should_not be_ok
      JSON.parse(last_response.body)['error'].should == "Invalid configuration"
    end
    
    it "should return valid JSON on success" do
      Net::HTTP.any_instance.should_receive(:request).and_return(OpenStruct.new(:code => "200", :body => lti_xml))
      get "/process_xml?url=http://www.example.com"
      last_response.should be_ok
      json = JSON.parse(last_response.body)
      json['title'].should == "Global Wiki"
      json['description'].should == "Institution-wide wiki tool with all the trimmings"
      json['settings'].should_not be_nil
      json['settings'].should == {
        "editor_button" => {"enabled"=>"true", "selection_width"=>"500", "selection_height"=>"300"},
        "icon_url" => "https://example.com/wiki.png",
        "labels" => {"en-US"=>"Build/Link to Wiki Page", "en-GB"=>"Build/Link to Wiki Page"},
        "resource_selection" => {"enabled"=>"true", "selection_width"=>"500", "selection_height"=>"300"},
        "text" => "Build/Link to Wiki Page"
      }
      json['icon_url'].should be_nil
    end
    
    it "should return JSONP if requested and error" do
      Net::HTTP.any_instance.should_receive(:request).and_raise(Timeout::Error.new("too long!"))#return(OpenStruct.new(:code => "200", :body => "")
      get "/process_xml?callback=bob&url=http://www.example.com"
      last_response.should_not be_ok
      last_response.body.should == "bob({\"error\":\"Request timed out\"});"
    end
    
    it "should return JSONp if requested and success" do
      Net::HTTP.any_instance.should_receive(:request).and_return(OpenStruct.new(:code => "200", :body => lti_xml))
      get "/process_xml?callback=bob&url=http://www.example.com"
      last_response.should be_ok
      last_response.body.should match(/^bob/)
    end
  end
  
  it "should propertly escape ampersands in URL arguments" do
    admin_permission = AdminPermission.new(apps: 'any')
    app = App.build_or_update('bacon', {
      'launch_url' => 'http://www.example.com?a=1&b=2&c=3',
      'id' => 'bacon',
      'pending' => false
    }, admin_permission)
    get "/tools/bacon/config.xml"
    last_response.should be_ok
    xml = Nokogiri(last_response.body)
    xml.css('blti|launch_url')[0].text.should == "http://www.example.com?a=1&b=2&c=3"
  end
  
  describe "config xml renders/redirects" do
    @apps = JSON.parse(File.read('./public/data/lti_examples.json')).select{|a| !a['pending'] }
    ap = AdminPermission.create(:username => "me", :apps => "any")
    @apps.each do |app|
      describe app['name'] do 
        before(:each) do
          App.build_or_update(app['id'], app, ap)
        end
        
        it "should not fail" do
          get "/tools/#{app['id']}/config.xml"
          if app['config_xml']
            last_response.should be_redirect
            last_response.location.should == app['config_xml']
          elsif app['config_options'] && app['config_options'].any?{|o| o['required'] }
            last_response.should be_ok
            last_response.body.should match(/Missing required value/)
            
            args = []
            app['config_options'].each{|o| args << "#{o['name']}=#{CGI.escape(o['value'] && o['value'].length > 0 ? o['value'] : "junk").to_s}" }
            get "/tools/#{app['id']}/config.xml?" + args.join("&")
            last_response.should be_ok
            last_response.body.should match(/blti/)
          else
            last_response.should be_ok
            last_response.body.should match(/blti/)
          end
          if(app['app_type'] == 'open_launch' || app['app_type'] == 'data') 
            xml = Nokogiri(last_response.body)
            xml.css('blti|launch_url').should_not be_empty
            xml.css('blti|launch_url')[0].text.should == "http://example.org/tool_redirect?id=#{app['id']}"
            if app['extensions'] && app['extensions'].include?('editor_button')
              xml.css("lticm|options[name='editor_button']").should_not be_empty
              xml.css("lticm|options[name='editor_button']")[0].css("lticm|property[name='url']").text.should == "http://example.org/tool_redirect?id=#{app['id']}"
            end
            if app['extensions'] && app['extensions'].include?('resource_selection')
              xml.css("lticm|options[name='resource_selection']").should_not be_empty
              xml.css("lticm|options[name='resource_selection']")[0].css("lticm|property[name='url']").text.should == "http://example.org/tool_redirect?id=#{app['id']}"
            end
          end
            
        end
        
        it "should error on POST requests with a useful message" do
          post "/tools/#{app['id']}/config.xml"
          if app['config_options'] && app['config_options'].any?{|o| o['required'] }
            last_response.should be_ok
            last_response.body.should match(/Missing required value/)
            
            args = []
            app['config_options'].each{|o| args << "#{o['name']}=#{CGI.escape(o['value'] && o['value'].length > 0 ? o['value'] : "junk").to_s}" }
            post "/tools/#{app['id']}/config.xml?" + args.join("&")
            last_response.should be_ok
            last_response.body.should match(/Invalid tool launch/)
            last_response.body.should match(/This tool was set up improperly/)
          else
            last_response.should be_ok
            last_response.body.should match(/Invalid tool launch/)
            last_response.body.should match(/This tool was set up improperly/)
          end
        end
      end
    end
    
    ["/config/course_navigation.xml",
    "/config/account_navigation.xml",
    "/config/user_navigation.xml",
    "/config/grade_passback.xml",
    "/config/editor_button.xml",
    "/config/editor_button2.xml",
    "/config/resource_selection.xml",
    "/config/editor_button_and_resource_selection.xml"].each do |path|
      describe path do
        it "should not fail" do
          get path
          last_response.should be_ok
          last_response.body.should match(/blti/)
        end
      end
    end
    
    describe "data json redirects" do
      it "should return stored json" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => '', 'data_json' => [{}, {}].to_json})
        get "/tools/tool/data.json"
        last_response.should be_ok
        last_response.body.should == [{}, {}].to_json
      end
      it "should redirect to external json" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => '', 'data_url' => "http://www.example.com"})
        get "/tools/tool/data.json"
        last_response.should be_redirect
        last_response.location.should == "http://www.example.com"
      end
      it "should return empty set if no json" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => ''})
        get "/tools/tool/data.json"
        last_response.should be_ok
        last_response.body.should == [].to_json
      end
    end
    
    it "should handle variables in custom fields" do
      app = App.create(:tool_id => 'tool', :pending => false, :settings => {'name' => 'tool', 'id' => 'tool', 'description' => '', 'logo_url' => 'http://www.example.com/logo.png'})
      app.settings['custom_fields'] = {'alex' => '{{ bob }}_four'}
      hash = app.settings 
      params = {'bob' => 'one_two_three'}
      host = "http://www.example.com"
      fields = XmlConfigParser.config_options(hash, params, host)['custom_fields']
      fields['alex'].should == 'one_two_three_four'
    end
    
    describe "image redirects" do
      it "should redirect logo requests" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => '', 'logo_url' => 'http://www.example.com/logo.png'})
        get "/tools/tool/logo.png"
        last_response.should be_redirect
        last_response.location.should == "http://www.example.com/logo.png"
      end
      it "should error if no logo url present" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => ''})
        get "/tools/tool/logo.png"
        last_response.should be_ok
        last_response.body.should == "Not Found"
      end
      it "should redirect banner requests" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => '', 'banner_url' => 'http://www.example.com/banner.png'})
        get "/tools/tool/banner.png"
        last_response.should be_redirect
        last_response.location.should == "http://www.example.com/banner.png"
      end
      it "should error if no banner url present" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => ''})
        get "/tools/tool/banner.png"
        last_response.should be_ok
        last_response.body.should == "Not Found"
      end
      it "should redirect icon requests" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => '', 'icon_url' => 'http://www.example.com/icon.png'})
        get "/tools/tool/icon.png"
        last_response.should be_redirect
        last_response.location.should == "http://www.example.com/icon.png"
      end
      it "should error if no icon url present" do
        App.create(:tool_id => 'tool', :pending => false, :settings => {'id' => 'tool', 'description' => ''})
        get "/tools/tool/icon.png"
        last_response.should be_ok
        last_response.body.should == "Not Found"
      end
    end
  end
    
end
