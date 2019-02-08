class MoodleUser < ApplicationRecord
  has_many :submissions
  belongs_to :report_run
end
