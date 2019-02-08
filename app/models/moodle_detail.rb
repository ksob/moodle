class MoodleDetail < ApplicationRecord
  belongs_to :user

  before_validation :strip_whitespace, :only => [:host, :token]
  before_validation :strip_url_params, :only => [:host]

  validates :host, :url => true if Rails.env.production?

  private
  def strip_whitespace
    self.host = self.host.strip unless self.host.nil?
    self.token = self.token.strip unless self.token.nil?
  end

  def strip_url_params
    self.host = self.host.split('?')[0]
  end
end
