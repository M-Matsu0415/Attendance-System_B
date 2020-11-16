class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50}
  validates :change_approval_superior_id, presence: true, on: [:request_one_month_change, :approval_one_month_change]
  validates :change_approval_status, presence: true, on: [:request_one_month_change, :approval_one_month_change]
  validates :started_at_after_approval, presence: true, on: :request_one_month_change
  validates :started_at, presence: true, on: :approval_one_month_change
  validates :overwork_finished_at, presence: true, on: :request_overwork
  validates :overwork_approval_status, presence: true, on: :request_overwork
  
  validates_acceptance_of :change_ok, allow_nil: false, on: :approval_one_month_change
  
  # 勤怠変更承認
  # 一般ユーザー申請
  # 勤怠編集において出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_after_approval_then_finished_at_after_approval_fast_if_invalid
  
  def started_at_after_approval_then_finished_at_after_approval_fast_if_invalid
    if change_next_day_check == false
      if started_at_after_approval.present? && finished_at_after_approval.present?
        errors.add(:started_at_after_approval, "より早い退勤時間は無効です") if started_at_after_approval > finished_at_after_approval
      end
    end
  end
end