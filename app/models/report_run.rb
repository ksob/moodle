class ReportRun < ApplicationRecord
  has_many :reports, dependent: :destroy
  has_many :moodle_users, dependent: :destroy
end
