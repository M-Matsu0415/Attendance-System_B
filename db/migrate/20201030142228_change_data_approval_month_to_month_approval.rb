class ChangeDataApprovalMonthToMonthApproval < ActiveRecord::Migration[5.1]
  def change
    change_column :month_approvals, :approval_month, :date
  end
end
