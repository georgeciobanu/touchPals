class User < ActiveRecord::Base
  belongs_to :partner, :class_name => 'User'
  # has_many :chats, :foreign_key
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  before_save :ensure_authentication_token


  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :authentication_token, :partner_id, :username,
                  :remaining_swaps;
                  
  def getPartner(options)
    found = false
    User.transaction do
      @partner = User.where("partner_id is NULL").lock(true).first
      
      # Not sure I need to check again
      # We are guaranteed to have partner_id == nil because we haven't been saved
      if @partner && @partner.partner_id == nil
        self.partner = @partner
        @partner.partner = self
        @partner.save
        found = true
        @jsonCommand = ActiveSupport::JSON.encode(cmd: "found_match", partner_name: @partner.username, token: @partner.authentication_token)
        TouchEnd::Application.config.redisConnection.publish 'chats', jsonCommand

        if options[:save]
          self.save
        end
      end
    end # Locking transaction
    return found
  end

end