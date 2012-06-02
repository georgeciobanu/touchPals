class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :text
      t.integer :user_id

      t.timestamps
    end
  end
end
