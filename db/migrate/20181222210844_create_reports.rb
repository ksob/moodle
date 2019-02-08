class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.references :user, foreign_key: true
      t.string :report_type
      t.string :contents

      t.timestamps
    end
  end
end
