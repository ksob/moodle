class AddStatusToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :status, :string
  end
end
