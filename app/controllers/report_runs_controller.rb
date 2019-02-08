class ReportRunsController < ApplicationController
  def index
    if params['report_type'] == 'graded'
      @report_type = 'graded'
      @report_runs = ReportRun.where(run_params: '')

      if current_user.email == 'ksobej@gmail.com'
        # all reports for admin
      else
        @report_runs = @report_runs.where(user_id: current_user.id)
      end

      @report_runs = @report_runs.order("created_at DESC").pluck(:created_at, :id, :run_params)
    else
      @report_type = 'not graded'
      @report_runs = ReportRun.where("run_params LIKE '%kiedy%'")

      if current_user.email == 'ksobej@gmail.com'
        # all reports for admin
      else
        @report_runs = @report_runs.where(user_id: current_user.id)
      end

      @report_runs = @report_runs.order("created_at DESC").pluck(:created_at, :id, :run_params)
    end
  end

end
