class AddPairIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :pair_id, :integer
  end
end
