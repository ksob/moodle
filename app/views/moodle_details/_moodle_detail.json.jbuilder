json.extract! moodle_detail, :id, :host, :token, :user_id, :created_at, :updated_at
json.url moodle_detail_url(moodle_detail, format: :json)
