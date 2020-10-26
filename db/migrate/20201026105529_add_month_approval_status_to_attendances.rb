class AddMonthApprovalStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_approval_status, :integer
  end
end
