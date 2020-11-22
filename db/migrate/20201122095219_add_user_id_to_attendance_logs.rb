class AddUserIdToAttendanceLogs < ActiveRecord::Migration[5.1]
  def change
    add_reference :attendance_logs, :user, foreign_key: true
  end
end
