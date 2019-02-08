class TeacherMailer < ApplicationMailer
  default from: %("Reports" <bot@raporty.example.com>)

  def notify_teacher(teacher_email, reports_hash, end_date, host)
    parreports_hash = JSON.parse reports_hash
    @courses = parreports_hash["courses"]
    @end_date = end_date
    @school_name = host

    mail(to: teacher_email, subject: 'Masz nieocenione zadania')
  end

  def notify_teacher_graded(teacher_email, reports_hash, host)
    parreports_hash = JSON.parse reports_hash
    @courses = parreports_hash["courses"]
    @teacher_email = teacher_email
    @school_name = host

    mail(to: teacher_email, subject: 'Raport studentów')
  end

  def notify_teacher_signin(teacher_email, email_contents, host)
    @email_contents = email_contents.gsub("\r\n", "<br>").gsub("\n", "<br>")
    @teacher_email = teacher_email
    @school_name = host

    mail(to: teacher_email, subject: 'Zaloguj się do platformy')
  end
end
