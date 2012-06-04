class SessionsController < Devise::SessionsController  
  def create
    respond_to do |format|
      # format.html { super }
      warden.authenticate!(:scope => :user, :recall => "registrations#auth_new")
      format.json {
        @days_left_with_partner = nil
        if current_user.date_connected
          @days_left_with_partner = 30 - ((Time.now - current_user.date_connected).to_i / 1.day)
        end
        
        render :status => 200, :json => { :session => { :error => "Success", :auth_token => current_user.authentication_token },
                :user => current_user, :partner_username => current_user.partner.try(:username),
                :remaining_swaps => current_user.remaining_swaps,:days_left => @days_left_with_partner }
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