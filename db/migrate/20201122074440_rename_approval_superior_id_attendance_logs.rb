class RenameApprovalSuperiorIdAttendanceLogs < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendance_logs, :approval_superior_id, :approval_superior_name
  end
end
