class AddLookingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :looking, :boolean
  end
end
