class AddTeacherEmailsAndSignInEmailTextToMoodleDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :moodle_details, :teacher_emails, :text
    add_column :moodle_details, :signin_email_text, :text
  end
end
