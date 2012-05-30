class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :from_user_id
      t.string :email

      t.timestamps
    end
  end
end
