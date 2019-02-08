require 'csv'

class GradedWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(host, token, user_id, course_idx_slice, report_run_id, is_last_run)

    Moodle::Api.configure({host: host, token: token
    })

    ###################
    ###################
    ###################
    ###################
    ################### TODO - when get response from Dariusz (after they upgrade it) use gradereport_user_get_grade_items function
    ################### to extract grades bulk way test it here and if works, implement on line 276
    ################### intechaning mod_assign_get_submission_status with gradereport_user_get_grade_items
    ################### remove break from 206 line
    ###################
    ###################

    parameters = { }

    courses = nil
    begin
      courses = Moodle::Api.core_course_get_courses(parameters)
    rescue SocketError => e
      sleep 15
      courses = Moodle::Api.core_course_get_courses(parameters)
    end

    raise "Podany 'Adres serwera' prawdopodobnie jest błędny!" if courses.nil?

    assignment_ids = []
    enrolled_users = {}
    moodle_users = {}
    result_hsh = {}
    courses.each_with_index do |course, crs_idx|
      next if !course_idx_slice.include?(crs_idx)
      parameters = { 'courseid' => course['id'] }

      #
      #
      # download enrolled users as this will be needed in next steps
      #
      #
      begin
        enrolled_users[course['id'].to_i] = Moodle::Api.core_enrol_get_enrolled_users(parameters)
      rescue SocketError => e
        sleep 15
        enrolled_users[course['id'].to_i] = Moodle::Api.core_enrol_get_enrolled_users(parameters)
      end


      # get total grades for the enrolled users
      #
      #
      #
      #
      users = enrolled_users[course['id'].to_i] # hash contains enrolled users grouped by course ids as keys
      #is_the_user_enrolled = false
      users.each_with_index do |user, loop_idx|
        sleep 1 if (loop_idx % 5) == 0

        #next if user['id'].to_i != MoodleUser.find(moodle_user_id).moodle_id.to_i
        next if user.is_a?(Array) # when it is exception like ["exception", "required_capability_exception"]
        next if user['roles'].nil? || (!user['roles'].any?) # because sometimes roles can be [] (empty array)

        # check if the user is really enrolled in this course
        # Note: this additional check is make because of some bug in core_enrol_get_enrolled_users as
        #       the function returns even some users that are not enrolled in this course (maybe those that were
        #       enrolled in the past but have been deleted? I don't know)
        enrolled_courses = []
        user['enrolledcourses'].each do |enrolled_course|
          enrolled_courses << enrolled_course['id']
        end if user.key?('enrolledcourses')

        next if !enrolled_courses.include?(course['id'].to_i)

        # setup data for updating moodle users table with emails
        moodle_users[user['id'].to_i] ||= {}
        moodle_users[user['id'].to_i][:email] = user['email']

        user['roles'].each do |role|
          # teacher = Nauczyciel bez praw edycji, editingteacher = Prowadzący,
          if role['shortname'] != 'teacher' && role['shortname'] != 'editingteacher' #&& role['shortname'] != 'manager'
            # is a student
            grades_parameters = { 'userid' => user['id'].to_s }

            begin
              moodle_users[user['id'].to_i][:grades] ||= Moodle::Api.gradereport_overview_get_course_grades(grades_parameters)
            rescue SocketError => e
              sleep 15
              moodle_users[user['id'].to_i][:grades] ||= Moodle::Api.gradereport_overview_get_course_grades(grades_parameters)
            end

            next
          end
        end

      end



      # pick only this course's (the each loop iterate) grades
      #
      #
      #
      users_passed = []
      users.each do |user|
        next if user.is_a?(Array)
        next if !moodle_users.key?(user['id'].to_i) # this occur for example when the user is
                                                    # skipped in previous block when he is not "really" enrolled
        grades = moodle_users[user['id'].to_i][:grades]
        next if grades.nil?
        MoodleUser.find_or_create_by(moodle_id: user['id'].to_i, report_run_id: report_run_id)
        grades['grades'].each do |grade|
          next if grade['courseid'].to_i != course['id'].to_i
          next if grade['grade'].nil? || grade['grade'].blank? || grade['grade'].length < 2
          users_passed << user['id']
        end
      end




      # assign to teacher
      #
      #
      #
      users.each do |user|
        #next if user['id'].to_i != MoodleUser.find(moodle_user_id).moodle_id.to_i
        next if user.is_a?(Array)
        next if user['roles'].nil? || (!user['roles'].any?) # because sometimes roles can be [] (empty array)

        # check if the user is really enrolled in this course
        # Note: this additional check is make because of some bug in core_enrol_get_enrolled_users as
        #       the function returns even some users that are not enrolled in this course (maybe those that were
        #       enrolled in the past but have been deleted? I don't know)
        enrolled_courses = []
        user['enrolledcourses'].each do |enrolled_course|
          enrolled_courses << enrolled_course['id']
        end if user.key?('enrolledcourses')
        next if !enrolled_courses.include?(course['id'].to_i)

        user['roles'].each do |role|
          # teacher = Nauczyciel bez praw edycji, editingteacher = Prowadzący,
          if role['shortname'] != 'teacher' && role['shortname'] != 'editingteacher'
            # is a student
          else # is a teacher
            result_hsh[user['email']] ||=
            { fullname: user['fullname'], courses: {} }

            t_course_name = course['fullname']
            result_hsh[user['email']][:courses][t_course_name] ||= {}

            result_hsh[user['email']][:courses][t_course_name][:user_ids] = users_passed

          end
        end
      end


    end


    #
    # update moodle users table with emails
    #
    # TODO: disable this after testing
    #
    MoodleUser.where(report_run_id: report_run_id).each do |moodle_user|
      moodle_id = moodle_user.moodle_id.to_i
      if moodle_users.key?(moodle_id)
        moodle_user.update!(
        email: moodle_users[moodle_id][:email]
        )
      end
    end


    logger.info  "Creating report for #{course_idx_slice.to_s}"

    the_report = Report.create(user_id: user_id, contents: result_hsh, report_type: 'graded', report_run_id: report_run_id)

    logger.info  "Report for #{course_idx_slice.to_s} created"


    if is_last_run == true
      email_addr = User.find(user_id).email
      logger.info  "Notifying user about report finish via email #{email_addr}"

      reports_by_teacher = get_reports_by_teacher report_run_id
      file_attachm = gen_csv(reports_by_teacher)

      ReportDoneMailer.notify_user(email_addr, report_run_id, 'graded', file_attachm).deliver_now
      ReportDoneMailer.notify_user('kamil_sobiera@onet.pl', report_run_id, 'graded', file_attachm).deliver_now
      logger.info  "Notifying user about report finish via email #{email_addr}: DONE"
    end

  rescue StandardError => error
    email_addr = User.find(user_id).email
    ReportDoneMailer.notify_user_about_error(email_addr, report_run_id, 'graded', error.message).deliver_now
    ReportDoneMailer.notify_user_about_error('kamil_sobiera@onet.pl', report_run_id, 'graded',  error.message).deliver_now
    logger.info  "Notifying user about error #{email_addr}: DONE"
  end # perform



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

end # class
