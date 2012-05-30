class Invite < ActiveRecord::Base
  attr_accessible :email, :from_user_id
  belongs_to :sender, :class_name => 'User', :foreign_key => :from_user_id
end