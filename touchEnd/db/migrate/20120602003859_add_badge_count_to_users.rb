class AddBadgeCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :badge_count, :integer
  end
end
