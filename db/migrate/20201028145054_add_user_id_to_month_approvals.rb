class AddUserIdToMonthApprovals < ActiveRecord::Migration[5.1]
  def change
    add_reference :month_approvals, :user, foreign_key: true
  end
end
