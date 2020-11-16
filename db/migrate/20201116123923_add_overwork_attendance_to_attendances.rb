class AddOverworkAttendanceToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_finished_at, :datetime
    add_column :attendances, :overwork_approval_superior_id, :integer
    add_column :attendances, :overwork_content, :string
    add_column :attendances, :overwork_approval_status, :integer
  end
end
