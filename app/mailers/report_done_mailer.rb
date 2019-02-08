class ReportDoneMailer < ApplicationMailer
  default from: %("Reports" <bot@raporty.example.com>)

  def notify_user(email_addr, report_run_id, report_type, file_attach=nil)
    @report_url = "http://www.raporty.example.com/reports?report_run_id=#{report_run_id}&report_type=#{report_type}"

    if !file_attach.nil?
      attachments['rap_csv.csv'] = file_attach
    end

    mail(to: "#{email_addr}", subject: 'Raport jest gotowy')
  end

  def notify_user_about_error(email_addr, report_run_id, report_type, error_message)
    @report_url = "http://www.raporty.example.com/reports?report_run_id=#{report_run_id}&report_type=#{report_type}"
    @error_message = error_message

    mail(to: "#{email_addr}", subject: 'Raport nieudany')
  end
end
