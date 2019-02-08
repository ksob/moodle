class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :submissions do |t|
      t.datetime :date_submitted
      t.datetime :date_graded
      t.integer :grade_raw
      t.string :item_module
      t.integer :item_instance_id
      t.integer :moodle_id
      t.references :moodle_user, foreign_key: true

      t.timestamps
    end
  end
end
