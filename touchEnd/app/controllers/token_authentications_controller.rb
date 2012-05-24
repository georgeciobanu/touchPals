class TokenAuthenticationsController < ApplicationController
  before_filter :authenticate_user!

    def create
      Rails.logger.info("Authentication Token created")
      @user = current_user
      @user.reset_authentication_token!
      redirect_to edit_user_registration_path(@user)
    end

    def destroy
      Rails.logger.info("Authentication Token destroyed")      
      @user = current_user
      @user.authentication_token = nil
      @user.save
      redirect_to edit_user_registration_path(@user)
    end  
end
