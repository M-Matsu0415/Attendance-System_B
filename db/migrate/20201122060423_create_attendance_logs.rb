class CreateAttendanceLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_logs do |t|
      t.date :worked_on_log
      t.datetime :started_at_log_before_change
      t.datetime :finished_at_log_before_change
      t.datetime :started_at_log_after_change
      t.datetime :finished_at_log_after_change
      t.integer :approval_superior_id
      t.datetime :approval_date

      t.timestamps
    end
  end
end
