class HomeController < ApplicationController
  before_action :authenticate_user!
  # TODO: deny more than one sidekiq worker running at once
  before_action :ensure_sidekiq_not_occupied, only: [:generate_notgraded_report, :generate_graded_report]

  def generate_notgraded_report
    raise "'Adres serwera' i 'Token' nie mogą być puste!" if current_user.moodle_detail.nil? ||
    current_user.moodle_detail.host.blank? || current_user.moodle_detail.token.blank?

    if Rails.env.production?
      ensure_token_valid
      ensure_sidekiq_running

      DummyWorker.perform_in(10.minutes)  # this is only for making sure the user not say
                                          # click the button assigned to this action in the same time
                                          # before the NotGradedWorker / GradedWorker is scheduled
    end

    end_date = Date.parse(params[:report][:end_date])
    puts end_date.to_time.to_i

    # TODO: remove unused user reference from Report as it is now in ReportRun
    report_run = ReportRun.create(
    user_id: current_user.id,
    run_params: "Do kiedy: #{end_date}",
    end_date: end_date)

    start_range = 0
    course_count = get_course_count

    idx = 0
    course_volume_for_single_worker = 30
    delay_minutes_for_worker = 2
    while start_range <= course_count
      end_range = start_range + course_volume_for_single_worker

      NotGradedWorker.perform_in((delay_minutes_for_worker * idx).minutes,
      current_user.moodle_detail.host,
      current_user.moodle_detail.token, end_date, current_user.id,
      (start_range..end_range).to_a, report_run.id,
      is_last_run?(course_volume_for_single_worker, start_range, course_count)
      )

      idx += 1
      start_range = end_range + 1
    end

  end


  def generate_graded_report
    raise "'Adres serwera' i 'Token' nie mogą być puste!" if current_user.moodle_detail.nil? ||
    current_user.moodle_detail.host.blank? || current_user.moodle_detail.token.blank?

    if Rails.env.production?
      ensure_token_valid
      ensure_sidekiq_running

      DummyWorker.perform_in(5.minutes) # this is only for making sure the user not say
                                        # click the button assigned to this action in the same time
                                        # before the NotGradedWorker / GradedWorker is scheduled
    end

    # TODO: remove unused user reference from Report as it is now in ReportRun
    report_run = ReportRun.create(
    user_id: current_user.id,
    run_params: "")

    start_range = 0
    course_count = get_course_count

    idx = 0
    course_volume_for_single_worker = 800
    delay_minutes_for_worker = 15
    while start_range <= course_count
      end_range = start_range + course_volume_for_single_worker

      GradedWorker.perform_in((delay_minutes_for_worker * idx).minutes,
      current_user.moodle_detail.host,
      current_user.moodle_detail.token, current_user.id,
      (start_range..end_range).to_a, report_run.id,
      is_last_run?(course_volume_for_single_worker, start_range, course_count)
      )

      idx += 1
      start_range = end_range + 1
    end

  end

  def generate_signin_report
    current_user.moodle_detail.teacher_emails = params['report']['emails']
    current_user.moodle_detail.signin_email_text = params['report']['email_text']
    current_user.moodle_detail.save

    raise "'Adres serwera' i 'Token' nie mogą być puste!" if current_user.moodle_detail.nil? ||
    current_user.moodle_detail.host.blank? || current_user.moodle_detail.token.blank?

    if Rails.env.production?
      ensure_token_valid
    end

    last_access = DateTime.now - (params[:report][:last_access]).to_i.days
    last_access = last_access.to_time.to_i

    Moodle::Api.configure({
      host: current_user.moodle_detail.host,
      token: current_user.moodle_detail.token
    })

    emails = params['report']['emails'].split("\r\n")
    emails = emails.map { |c| c.strip }
    emails = emails.reject { |c| c.empty? }
    parameters = { 'field'=> 'email' }
    emails.each_with_index do |email, idx|
      parameters.merge!( "values[#{idx}]" => email )
    end

    @last_access_times = {}
    result = Moodle::Api.core_user_get_users_by_field(parameters)
    result.each do |person|
      if person['lastaccess'].to_i <= last_access
        @last_access_times[person['email']] = person['lastaccess']
      end
    end
  end

  def index
    @moodle_detail = current_user.moodle_detail
    @moodle_detail ||= MoodleDetail.new
  end

  private

  # TODO: deny more than one sidekiq worker running at once
  def ensure_sidekiq_not_occupied
    scheduled = Sidekiq::ScheduledSet.new # those under tab 'Zaplanowane'
    queued = Sidekiq::Queue.new # those under tab 'Zakolejkowane'
    busy = Sidekiq::Workers.new # those under tab 'Zajęte'

    logger.info "#{scheduled.size} | #{queued.size} | #{ busy.size}"

    is_occupied = false
    is_occupied = true if scheduled.size > 0 || queued.size > 0 || busy.size > 0
    err_msg = "Jeden z generatorów jest już uruchomiony, nie może działać więcej niż jeden na raz!"

    redirect_to root_path, :flash => { :error => err_msg } unless !is_occupied
  end

  def is_last_run?(course_volume_for_single_worker, end_range, course_count)
    (end_range + course_volume_for_single_worker) >= course_count
  end

  def get_course_count
    Moodle::Api.configure({
      host: current_user.moodle_detail.host,
      token: current_user.moodle_detail.token
    })
    parameters = { }
    all_courses = Moodle::Api.core_course_get_courses(parameters)

    all_courses.count
  end

  def ensure_token_valid
    Moodle::Api.configure({
      host: current_user.moodle_detail.host,
      token: current_user.moodle_detail.token
    })

    parameters = { }
    result = Moodle::Api.core_course_get_courses(parameters)
    raise result["message"] if result.is_a?(Hash) && result.key?("exception")
  end

  def ensure_sidekiq_running
    ps = Sidekiq::ProcessSet.new

    if ps.size < 1
      job = fork do
        # TODO: make it adjustable from hight level, not hard coded
        if Rails.env.production?
          exec "/usr/local/rvm/gems/ruby-2.5.1/bin/bundle exec sidekiq -c 1 RAILS_ENV=production"
        else
          exec "/home/p/.rbenv/shims/bundle exec sidekiq -c 1 RAILS_ENV=development"
        end
      end

      Process.detach(job)
    end
  end
end
