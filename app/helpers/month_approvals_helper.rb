module MonthApprovalsHelper

# 上長ユーザーが自分宛てに来ている一ヶ月承認申請の数をカウント
# 上長の勤怠画面の一ヶ月承認申請のお知らせ表示に使用
# ユーザー削除機能実行時に削除されるユーザーが上長であるか否か判断するためにまずカウントする。
  def month_approval_count(superior_id)
    if MonthApproval.where(approval_superior_id: superior_id, approval_status: 1).present?
      month_approvals = MonthApproval.where(approval_superior_id: superior_id, approval_status: 1)
      return month_approvals.count
    else
      return 0
    end
  end

# 画面を開いているユーザーが一ヶ月分の承認申請を提出しているかを判断
  def search_current_month_approval
    if @month_approval = MonthApproval.find_by(applicant_user_id: @user.id, approval_month: @attendances.first.worked_on)
    # 勤怠画面を開いているユーザーが提出済の一ヶ月分の承認申請をuser_idで検索しインスタンス変数に代入
      return @month_approval
    else
      return false
    end
  end
  
end
