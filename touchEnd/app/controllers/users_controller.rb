class UsersController < ApplicationController
  before_filter :authenticate_user!

  def update
    # TODO(george): This should be moved in the model
    if params[:username] && params[:username] != ""
      current_user.username = params[:username]
      @jsonCommand = ActiveSupport::JSON.encode(cmd: "partner_name_change", partner_name: current_user.username, 
          token: current_user.partner.authentication_token)
      TouchEnd::Application.config.redisConnection.publish 'chats', @jsonCommand
    end
    
    if params[:apn_token]
      current_user.apn_token = params[:apn_token]
    end

    current_user.save

    render :json => current_user
  end

  def elope
    if current_user.elope params[:receipt]
      render :json => current_user, :status => :ok
    else
      render :json => current_user, :status => :"i'm_a_teapot"
    end
  end
  
  def info
    render :json => { :user => current_user, :partner_username => current_user.partner.try(:username),
            :remaining_swaps => current_user.remaining_swaps}
  end    
end