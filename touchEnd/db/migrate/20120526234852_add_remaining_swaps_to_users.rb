class AddRemainingSwapsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remaining_swaps, :integer
  end
end
