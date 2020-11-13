class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50}
  
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_then_finished_at_fast_if_invalid
  # 勤怠編集において出勤時間が存在しない場合は無効
  validate :edit_one_month_is_invalid_without_a_started_at_after_approval, on: :update_one_month
  # 勤怠編集において出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_after_approval_then_finished_at_after_approval_fast_if_invalid, on: :update_one_month
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
    # started_atがない(nil)、かつfinished_atが存在する場合にエラーコメント出力する。
    # add：errorオブジェクトにコメントを追加する。
  end
  
  def started_at_then_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  def edit_one_month_is_invalid_without_a_started_at_after_approval
    if started_at_after_approval.present?
      errors.add(:started_at_after_approval, "の入力がない日があります")
    end
  end
  
  def started_at_after_approval_then_finished_at_after_approval_fast_if_invalid
    if started_at_after_approval.present? && finished_at_after_approval.present?
      errors.add(:started_at_after_approval, "より早い退勤時間は無効です") if started_at_after_approval > finished_at_after_approval
    end
  end
end
