class AddOverworkNextDayToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_next_day, :boolean
  end
end
