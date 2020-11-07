class MonthApproval < ApplicationRecord
  belongs_to :user
  validates_acceptance_of :change_ok, allow_nil: false, on: :update_month_approvals
end
