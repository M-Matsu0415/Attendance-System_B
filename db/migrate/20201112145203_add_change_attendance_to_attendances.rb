class AddChangeAttendanceToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_at_after_approval, :datetime
    add_column :attendances, :finished_at_after_approval, :datetime
    add_column :attendances, :change_approval_superior_id, :integer
    add_column :attendances, :change_approval_status, :integer
  end
end
