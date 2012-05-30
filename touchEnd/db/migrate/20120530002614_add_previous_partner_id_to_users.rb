class AddPreviousPartnerIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :previous_partner_id, :integer
  end
end
