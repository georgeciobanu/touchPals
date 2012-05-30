class UsersController < ApplicationController
  before_filter :authenticate_user!

  def update
    # TODO(george): This should be moved in the model
    
    respond_to do |format|
      if params[:username] != nil && params[:username] != ""
        current_user.update_attributes :username => params[:username]
        @jsonCommand = ActiveSupport::JSON.encode(cmd: "partner_name_change", partner_name: current_user.username, 
            token: current_user.partner.authentication_token)
        TouchEnd::Application.config.redisConnection.publish 'chats', @jsonCommand
        format.json { render :json => @current_user }
      else
        # format.html { render action: "edit" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def elope
    render :json => current_user.elope
  end
end
