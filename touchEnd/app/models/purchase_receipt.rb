class PurchaseReceipt < ActiveRecord::Base
  attr_accessible :receipt, :user_id
  belongs_to :user
end
