require 'csv'

class ReportsController < ApplicationController
  def index
    @report_run_id = params['report_run_id']
    @report_type = params['report_type']

    reports = Report
    .where(report_run_id: params['report_run_id'])

    # TODO: make it configurable from higher level, not hard coded
    if current_user.email == 'ksobej@gmail.com'
      # all reports for admin
    else
      reports = reports.where(user_id: current_user.id)
    end

    if reports.count > 0
      if params['report_type'] == 'graded'
      else
        @end_date = reports.first.report_run.end_date
      end

      reports = reports.pluck(:contents)

      @reports_by_teacher = {}
      reports.each do |report|
        report.each_pair do |teacher_email, hsh|
          if hsh['courses']
            @reports_by_teacher[teacher_email] ||= {}
            @reports_by_teacher[teacher_email]['fullname'] = hsh['fullname'] if params['report_type'] != 'graded'
            @reports_by_teacher[teacher_email]['courses'] ||= {}
            @reports_by_teacher[teacher_email]['courses'].merge!(hsh['courses'])
          end
        end
      end

      if params['report_type'] == 'graded'
        render 'index_with_details_graded'
      else
        render 'index_with_details'
      end
    end
  end

  def show
    @notgraded_submissions = Report.find(params[:id]).contents
  end

  def notify_teacher
    TeacherMailer.notify_teacher(
    params['teacher_email'], params['reports_hash'], params['end_date'], current_user.moodle_detail.host
    ).deliver_now
  end

  def notify_teacher_graded
    TeacherMailer.notify_teacher_graded(
    params['teacher_email'], params['reports_hash'], current_user.moodle_detail.host
    ).deliver_now
  end

  def notify_teacher_signin
    TeacherMailer.notify_teacher_signin(
    params['teacher_email'], params['email_contents'], current_user.moodle_detail.host
    ).deliver_now
  end

  def dl_csv_graded
    reports_by_teacher = get_reports_by_teacher params['report_run_id']

    respond_to do |format|
      format.html
      format.csv { send_data gen_csv(reports_by_teacher), filename: "raport-zaliczonych-stud-#{Date.today}.csv" }
    end
  end

  private

  def get_reports_by_teacher report_run_id
    reports = Report
    .where(report_run_id: report_run_id)

    reports = reports.pluck(:contents)

    reports_by_teacher = {}
    reports.each do |report|
      report.each_pair do |teacher_email, hsh|
        if hsh['courses']
          reports_by_teacher[teacher_email] ||= {}
          reports_by_teacher[teacher_email]['fullname'] = hsh['fullname'] if params['report_type'] != 'graded'
          reports_by_teacher[teacher_email]['courses'] ||= {}
          reports_by_teacher[teacher_email]['courses'].merge!(hsh['courses'])
        end
      end
    end

    reports_by_teacher
  end

  def gen_csv reports_by_teacher
    theheader = "Email nauczyciela,Nazwa kursu,Zaliczonych studentów (liczba)".split(',')
    CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << theheader

      reports_by_teacher.each_pair do |teacher_email, hsh|
        hsh["courses"].each_pair do |course_name, course_hsh|
          csv << [teacher_email, course_name, course_hsh['user_ids'].count]
        end
      end
    end
  end

end
