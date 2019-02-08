class AddEndDateToReportRuns < ActiveRecord::Migration[5.2]
  def change
    add_column :report_runs, :end_date, :date
  end
end
