class AddChangeNextDayCheckToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_next_day_check, :boolean
  end
end
