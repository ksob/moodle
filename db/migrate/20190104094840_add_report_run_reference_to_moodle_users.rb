class AddReportRunReferenceToMoodleUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :moodle_users, :report_run, foreign_key: true
  end
end
