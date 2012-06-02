class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :reporter_id
      t.integer :reportee_id

      t.timestamps
    end
  end
end
