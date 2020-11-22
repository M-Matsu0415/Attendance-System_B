class ChangeDataApprovalSuperiorIdToApprovalSuperiorName < ActiveRecord::Migration[5.1]
  def change
    change_column :attendance_logs, :approval_superior_id, :string
  end
end
