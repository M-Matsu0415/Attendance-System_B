class AddRequestedOverworkFinishedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :requested_overwork_finished_at, :datetime
  end
end
