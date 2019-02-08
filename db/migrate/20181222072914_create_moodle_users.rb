class CreateMoodleUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :moodle_users do |t|
      t.string :profile_image_url
      t.string :full_name
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :moodle_id

      t.timestamps
    end
  end
end
