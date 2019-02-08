class AddReportRunReferenceToReports < ActiveRecord::Migration[5.2]
  def change
    add_reference :reports, :report_run, foreign_key: true
  end
end
