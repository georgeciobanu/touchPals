class CreatePurchaseReceipts < ActiveRecord::Migration
  def change
    create_table :purchase_receipts do |t|
      t.string :receipt
      t.integer :user_id

      t.timestamps
    end
  end
end
