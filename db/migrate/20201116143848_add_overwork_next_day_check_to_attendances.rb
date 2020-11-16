class AddOverworkNextDayCheckToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_next_day_check, :boolean
  end
end
