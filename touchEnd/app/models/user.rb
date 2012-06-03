class User < ActiveRecord::Base
  belongs_to :partner, :class_name => 'User'
  belongs_to :previous_partner, :class_name => 'User', :foreign_key => :previous_partner_id
  # has_many :chats, :foreign_key
  has_many :invites, :class_name => 'Invite', :foreign_key => :from_user_id
  has_many :feedbacks
  has_many :reports 
  has_many :purchase_receipts
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  before_save :ensure_authentication_token

  valid_email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  
  validates :email, presence: true, 
                    format: {with: valid_email_regex},
                    uniqueness: { case_sensitive: false }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :authentication_token, :partner_id, :username,
                  :remaining_swaps, :badge_count, :apn_token;

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
      
      if @partner && @partner.partner_id == nil
        self.partner = @partner
        @partner.partner = self
        @partner.save
        found = true
        @jsonCommand = ActiveSupport::JSON.encode(cmd: "found_match", partner_name: self.username,
            token: @partner.authentication_token)
        @jsonCommand = ActiveSupport::JSON.encode(cmd: "found_match", partner_name: @partner.username,
            token: self.authentication_token)

        TouchEnd::Application.config.redisConnection.publish 'chats', @jsonCommand
        
        if self.id && self.apn_token
          APNS.send_notification(self.apn_token, 'The matchmaker found a partner! Meet ' + @partner.username)
        end
        if @partner && @partner.apn_token
          APNS.send_notification(@partner.apn_token, 'The matchmaker found a partner! Meet ' + self.username)
        end
        
        # If this is when we are created, the caller will do the save
        if self.id != nil
          self.save
        end
      end
    end # Locking transaction
    
    return found
  end

  def elope(receipt)
    Rails.logger.info("Receipt below")
    Rails.logger.info(receipt)
    User.transaction do
      @partner = self.partner
      # Users can only elope if they have a receipt or if they have a remaining swap
      
      if @partner.try(:partner) != self or self.partner == nil or 
        (self.remaining_swaps == 0 && !receipt)
        throw "Cannot divorce. Please try again"
      end

      @partner.previous_partner_id = self.id
      @partner.partner = nil
      @partner.save

      self.previous_partner_id = self.partner.id
      self.partner = nil
      if receipt && receipt != ""
        Rails.logger.info("I got a receipt!")
        PurchaseReceipt.create(receipt: receipt, user_id: self.id)
      else
        self.remaining_swaps -= 1
      end

      self.save

      @jsonCommand = ActiveSupport::JSON.encode(cmd: "divorce", token: @partner.authentication_token)
      TouchEnd::Application.config.redisConnection.publish 'chats', @jsonCommand
    end # Transaction

    # TODO(george): Create a way to reconnect to redisClient
    # Let the partner know that the other person divorced
    
    # TODO(george): gotta have previousPartner
    # TODO(george): three karma points, if three people divorce from you we take a swap away from you
    puts "Starting to get a partner"
    self.getPartner
    
    # TODO(george): If the prev partner wasn't active, they should not be given a new partner
    self.previous_partner.try(:getPartner)

    return true
  end

end