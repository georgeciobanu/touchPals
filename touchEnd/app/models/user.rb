class User < ActiveRecord::Base
  belongs_to :partner, :class_name => 'User'
  belongs_to :previous_partner, :class_name => 'User', :foreign_key => :previous_partner_id
  # has_many :chats, :foreign_key
  has_many :invites, :class_name => 'Invite', :foreign_key => :from_user_id
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  before_save :ensure_authentication_token


  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :authentication_token, :partner_id, :username,
                  :remaining_swaps;

  def getPartner
    if self.partner_id != nil
      throw "You need to divorce first"
    end
    
    found = false
    User.transaction do
      # Check that they do not have a partner
      # and that I am not one of their previous partners - this is tricky since I can sometimes have a NULL ID
      # which causes "previous_partner_id is NULL OR previous_partner_id <> :my_id"
      # and that it is not me :-)
      @query = "partner_id is NULL AND id <> :my_id AND (previous_partner_id is NULL OR previous_partner_id <> :my_id)"
      if self.id == nil
        # Simpler query if the current user is just being created
        @query = "partner_id is NULL"
      end

      @partner = User.where(@query, {:previous_partner_id => self.previous_partner_id, :my_id => self.id} ).lock(true).first

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

        if self.id != nil
          self.save
        end
      end
    end # Locking transaction
    return found
  end

  def elope    
    User.transaction do
      @partner = self.partner
      if @partner.try(:partner) != self or self.partner == nil or self.remaining_swaps == 0
        throw "Cannot divorce. Please try again"
      end
      
      @old_partner_token = @partner.authentication_token

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
    self.getPartner
    self.previous_partner.try(:getPartner)

    return true
  end

end