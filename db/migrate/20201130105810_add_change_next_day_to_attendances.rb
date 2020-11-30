class AddChangeNextDayToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_next_day, :boolean
  end
end
