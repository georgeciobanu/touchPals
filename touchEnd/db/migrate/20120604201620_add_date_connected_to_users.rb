class AddDateConnectedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :date_connected, :datetime
  end
end
