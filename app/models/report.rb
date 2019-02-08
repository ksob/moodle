class Report < ApplicationRecord
  belongs_to :user
  belongs_to :report_run

  serialize :contents, JSON
end
