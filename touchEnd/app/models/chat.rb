class Chat < ActiveRecord::Base
  attr_accessible :receiver_id, :sender_id, :text
end
