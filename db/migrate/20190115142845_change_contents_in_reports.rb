class ChangeContentsInReports < ActiveRecord::Migration[5.2]
  def change
  	change_column :reports, :contents, :text
  end
end
