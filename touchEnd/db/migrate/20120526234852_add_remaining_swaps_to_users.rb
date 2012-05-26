class AddRemainingSwapsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remining_swaps, :integer
  end
end
