class CreateReportRuns < ActiveRecord::Migration[5.2]
  def change
    create_table :report_runs do |t|
      t.references :user, foreign_key: true
      t.string :run_params

      t.timestamps
    end
  end
end
