require 'sinatra/base'
require 'sanitize'

module Sinatra
  module Admin
    def self.registered(app)
      app.helpers Admin::Helpers
      
      app.get "/admin" do
        @data_view = "admin"
        admin_check
        erb :admin
      end
      
      app.get "/propose" do
        @data_view = "admin"
        redirect to("/") unless session['user_key']
        erb :propose
      end
      
      app.get "/api/v1/admin/permissions" do
        admin_check
        @permissions = AdminPermission.all.sort_by{|p| [(p.apps == 'any' ? 0 : 1), p.id] }
        @permissions.map(&:as_json).to_json
      end
      
      app.delete "/api/v1/admin/permissions/:id" do
        admin_check
        @permission = AdminPermission.first(:id => params[:id])
        @permission.destroy
        @permission.to_json
      end
      
      app.post "/api/v1/admin/permissions" do
        admin_check
        @permission = AdminPermission.create(:username => params['username'], :apps => params['apps'])
        @permission.to_json
      end
      
      app.put "/api/v1/admin/permissions/:id" do
        admin_check
        @permission = AdminPermission.first(:id => params[:id])
        @permission.apps = params['apps']
        @permission.save
        @permission.to_json
      end
      
      app.post "/api/v1/apps" do
        return "An app with the id \"#{params['id']}\" already exists or has been proposed" if App.first(:tool_id => params['id'])
        if App.first(:tool_id => params['id']).nil? && session['user_key']
          @pending = true
        else
          admin_check(params['id'])
        end
        @app = App.build_or_update(params['id'], params, admin_permission, session['user_key'])
        @app.save
        @app.to_json
        # redirect to("/index.html?tool=#{@app.tool_id}")
      end
      
      app.put "/api/v1/apps/:tool_id" do
        admin_check(params['tool_id'])
        @app = App.build_or_update(params['tool_id'], params, admin_permission)
        @app.to_json
        # redirect to("/index.html?tool=#{@app.tool_id}")
      end
    end  
      
    module Helpers
      def admin_check(tool_id='any')
        permission = AdminPermission.first(:username => "@#{session['user_key']}")
        halt "No" unless permission && permission.allowed_access?(tool_id)
      end
    end
  end 
  register Admin
end