class MonthApproval < ApplicationRecord
  belongs_to :user
  validates :applicant_user_id, presence: true
  validates :approval_superior_id, presence: true
  validates :approval_status, presence: true
  validates :approval_month, presence: true
  validates_acceptance_of :change_ok, allow_nil: false, on: :update_month_approvals
end
