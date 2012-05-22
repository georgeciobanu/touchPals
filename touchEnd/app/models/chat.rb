class Chat < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  belongs_to :receiver, :class_name => 'User'
  

  attr_accessible :receiver_id, :sender_id, :text
end