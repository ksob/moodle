class CreateMoodleDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :moodle_details do |t|
      t.string :host
      t.string :token
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
