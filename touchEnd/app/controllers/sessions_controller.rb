class SessionsController < Devise::SessionsController  
  def create
    respond_to do |format|
      # format.html { super }
      warden.authenticate!(:scope => :user, :recall => "registrations#auth_new")
      format.json {
        render :status => 200, :json => { :session => { :error => "Success", :auth_token => current_user.authentication_token },
                :user => current_user, :partner_username => current_user.partner && current_user.partner.username,
                :remaining_swaps => current_user.remaining_swaps}
        }
    end
  end

  def destroy
    respond_to do |format|
      # format.html { super }
      # format.xml {
      #   warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
      #   current_user.authentication_token = nil
      #   render :xml => {}.to_xml, :status => :ok
      # }

      format.json {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        current_user.authentication_token = nil
        render :json => {}.to_json, :status => :ok
      }
    end
  end
end