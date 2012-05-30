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
      # If they don't have a partner and I haven't had them as a partner before
      @partner = User.where("partner_id is NULL AND (previous_partner_id is NULL OR previous_partner_id <> :my_previous_partner_id)",
      {:previous_partner_id => self.previous_partner_id} ).lock(true).first

      # Not sure I need to check again
      # We are guaranteed to have partner_id == nil because we haven't been saved
      if @partner && @partner.partner_id == nil
        self.partner = @partner
        @partner.partner = self
        @partner.save
        found = true
        @jsonCommand = ActiveSupport::JSON.encode(cmd: "found_match", partner_name: @partner.username, 
            token: @partner.authentication_token)
        TouchEnd::Application.config.redisConnection.publish 'chats', @jsonCommand

        if options[:save]
          self.save
        end
      end
    end # Locking transaction
    return found
  end

  def elope    
    User.transaction do
      @partner = self.partner
      @old_partner_token = @partner.authentication_token
      




      if @partner.partner != self or self.partner == nil or self.remaining_swaps == 0
        throw "Cannot divorce. Please try again"
      end

      @partner.previous_partner_id = self.id      
      @partner.partner = nil
      @partner.save
      
      self.previous_partner_id = self.partner.id
      self.partner = nil
      self.remaining_swaps -= 1

      self.save
       
      @jsonCommand = ActiveSupport::JSON.encode(cmd: "divorce", token: @old_partner_token)
      TouchEnd::Application.config.redisConnection.publish 'chats', @jsonCommand
    end # Transaction

    # TODO(george): Create a way to reconnect to redisClient
    # Let the partner know that the other person divorced
    
    # TODO(george): gotta have previousPartner
    # TODO(george): three karma points, if three people divorce from you we take a swap away from you
    puts "Starting to get a partner"
    self.getPartner({:save => true})
    return true
  end

end