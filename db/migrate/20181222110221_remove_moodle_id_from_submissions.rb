class RemoveMoodleIdFromSubmissions < ActiveRecord::Migration[5.2]
  def change
    remove_column :submissions, :moodle_id, :integer
  end
end
