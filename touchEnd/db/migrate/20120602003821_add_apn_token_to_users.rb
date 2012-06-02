class AddApnTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :apn_token, :string
  end
end
