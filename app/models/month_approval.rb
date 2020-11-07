class MonthApproval < ApplicationRecord
  validates_acceptance_of :change_ok, allow_nil: false
end
