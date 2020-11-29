class AttendanceLog < ApplicationRecord
  belongs_to :user
  
  validates :worked_on_log, presence: true
  validates :approval_superior_name, presence: true
  validates :approval_date, presence: true
end
