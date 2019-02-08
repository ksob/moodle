class NotGradedWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(host, token, end_date, user_id, course_idx_slice, report_run_id, is_last_run)
    Moodle::Api.configure({host: host, token: token
    })

    ###################
    ###################
    ###################
    ###################
    ################ TODO - when get response from Dariusz (after they upgrade it) use gradereport_user_get_grade_items function
    ################### to extract grades bulk way test it here and if works, implement on line 276
    ################### intechaning mod_assign_get_submission_status with gradereport_user_get_grade_items
    ################### remove break from 206 line
    ###################
    ###################

    parameters = { }

    courses = Moodle::Api.core_course_get_courses(parameters)

    raise "Podany 'Adres serwera' prawdopodobnie jest błędny!" if courses.nil?

    assignment_ids = []
    enrolled_users = {}
    global_assignments = {}
    courses.each_with_index do |course, crs_idx|
      next if !course_idx_slice.include?(crs_idx)

      parameters = { 'courseid' => course['id'] }

      #
      #
      # get all assignments
      #
      #
      contents = Moodle::Api.core_course_get_contents(parameters)
      contents.each do |content_item|
        next if content_item['uservisible'] == false
        next if content_item['modules'].nil?

        content_item['modules'].each do |module_item|
          next if module_item['uservisible'] == false
          next if module_item['modname'] != 'assign'

          #
          # module_item['name'] contains name of the assignment (nazwa zadania)
          #
          # module_item['instance'] contains id of the assignment
          #
          # content_item['name'] contains name of the topic the assignment is
          # 	contained in (i.e. the parent/subject the assignment is contained it)
          #
          global_assignments[module_item['instance'].to_i] = {contents: [course['id'], module_item['instance'], course['fullname'], content_item['name'], module_item['name']]}
        end
      end

      #
      #
      # download enrolled users as this will be needed in next steps
      #
      #
      enrolled_users[course['id'].to_i] = Moodle::Api.core_enrol_get_enrolled_users(parameters)
    end


    #
    #
    #
    #
    # get all submissions
    #
    #
    logger.debug 'get all submissions'

    parameters_1 = {}
    parameters_2 = {}
    global_assignments.each_with_index do |(key,value),idx|
      if idx > 500
        parameters_2.merge!("assignmentids[#{idx}]" => value[:contents][1])
      else
        parameters_1.merge!("assignmentids[#{idx}]" => value[:contents][1])
      end
    end

    assignmentid_userid_array = []

    submission_list = []
    [parameters_1, parameters_2].each do |parameters|
      logger.debug parameters
      assignments = Moodle::Api.mod_assign_get_submissions(parameters)
      assignments = assignments['assignments']
      assignments.each do |assignment|

        assignment['submissions'].each_with_index do |submission, submission_idx|
          next if submission['gradingstatus'] != 'notgraded'

          # TODO: find out if needs additional conditions as found some 'graded' submissions with 'new' status
          next if submission['status'] != 'submitted'

          next if submission['timemodified'] >= end_date.to_time.to_i

          #
          # pre-create a user
          #
          cu_user = MoodleUser.find_or_create_by(moodle_id: submission['userid'], report_run_id: report_run_id)

          # TODO: make so that moodle_user_id refers to User.moodle_id field instead of the User.id
          #       to remove possibilities for bugs / misunderstanding

          submission_list << {
            item_instance_id: assignment['assignmentid'],
            moodle_user_id: cu_user.id,
            status: submission['status']
          }
        end
      end if !assignments.nil?
    end


    notgraded_submissions = {}
    moodle_users = {}

    submission_list.each do |in_hash|

      item_instance_id = in_hash[:item_instance_id]
      moodle_user_id = in_hash[:moodle_user_id]

      global_assignments.each_with_index do |(global_assignments_key, courseid_assignementid), assign_idx|
        logger.debug "#{courseid_assignementid[:contents][1]} == #{item_instance_id}"
        if courseid_assignementid[:contents][1].to_i == item_instance_id.to_i

          users = enrolled_users[courseid_assignementid[:contents][0].to_i] # hash contains enrolled users grouped by course ids as keys
          is_the_user_enrolled = false
          users.each do |user|
            next if user['id'].to_i != MoodleUser.find(moodle_user_id).moodle_id.to_i
            next if user['roles'].nil? || (!user['roles'].any?) # because sometimes roles can be [] (empty array)

            # check if the user is really enrolled in this course
            # Note: this additional check is make because of some bug in core_enrol_get_enrolled_users as
            #       the function returns even some users that are not enrolled in this course (maybe those that were
            #       enrolled in the past but have been deleted? I don't know)
            enrolled_courses = []
            user['enrolledcourses'].each do |enrolled_course|
              enrolled_courses << enrolled_course['id']
            end
            next if !enrolled_courses.include?(courseid_assignementid[:contents][0].to_i)
            is_the_user_enrolled = true

            # setup data for updating moodle users table with emails
            moodle_users[user['id']] = {}
            moodle_users[user['id']][:email] = user['email']
          end

          # find the teacher and assign the current submission (with moodle_user_id) to the teacher
          if is_the_user_enrolled
            users.each do |user|
              user['roles'].each do |role|
                # teacher = Nauczyciel bez praw edycji, editingteacher = Prowadzący,
                next if role['shortname'] != 'teacher' && role['shortname'] != 'editingteacher' #&& role['shortname'] != 'manager'

                notgraded_submissions[user['email']] ||=
                { fullname: user['fullname'], courses: {} }

                t_course_name = courseid_assignementid[:contents][2]
                notgraded_submissions[user['email']][:courses][t_course_name] ||= {}

                t_topic_name = courseid_assignementid[:contents][3]
                notgraded_submissions[user['email']][:courses][t_course_name][t_topic_name] ||= {}

                t_assignment_name = courseid_assignementid[:contents][4]
                notgraded_submissions[user['email']][:courses][t_course_name][t_topic_name][t_assignment_name] ||= []

                # add user id to the array
                notgraded_submissions[user['email']][:courses][t_course_name][t_topic_name][t_assignment_name] << moodle_user_id
              end
            end
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

    #
    # report
    #
    logger.info  "Creating report for #{course_idx_slice.to_s}"
    logger.info  "user_id ====== #{user_id}"
    logger.info  "report_run_id ====== #{report_run_id}"
    logger.info  "notgraded_submissions ===== #{notgraded_submissions}"
    the_report = Report.create(user_id: user_id, contents: notgraded_submissions, report_type: 'not graded', report_run_id: report_run_id)
    logger.info  "Report for #{course_idx_slice.to_s} created"

    if is_last_run == true
      email_addr = User.find(user_id).email
      logger.info  "Notifying user about report finish via email #{email_addr}"
      ReportDoneMailer.notify_user(email_addr, report_run_id, 'not graded').deliver_now
      ReportDoneMailer.notify_user('kamil_sobiera@onet.pl', report_run_id, 'not graded').deliver_now
      logger.info  "Notifying user about report finish via email #{email_addr}: DONE"
    end

  end
end
