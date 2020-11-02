module MonthApprovalsHelper

# 上長ユーザーが自分宛てに来ている一ヶ月承認申請の数をカウント
# 上長の勤怠画面の一ヶ月承認申請のお知らせ表示に使用
  def month_approval_count(superior_id)
    if MonthApproval.where(approval_superior_id: superior_id).present?
      month_approvals = MonthApproval.where(approval_superior_id: superior_id)
      return month_approvals.count
    else
      return 0
    end
  end

# 画面を開いているユーザーが一ヶ月分の承認申請を提出しているかを判断
  def search_current_month_approval
    current_user_month_approval = MonthApproval.find_by(user_id: @user.id)
    # 勤怠画面を開いているユーザーが提出済の一ヶ月分の承認申請をuser_idで検索しローカル変数に代入
    if current_user_month_approval.approval_month.present?
    # 提出済の一ヶ月分の承認申請が存在する場合のみ処理を実行
      if current_user_month_approval.approval_month.mon == @attendances.first.worked_on.mon
      # 提出済の一ヶ月分の承認申請と勤怠画面の月が一致する場合は、trueを返答。
      # @attendancesは一ヶ月の日数分あるので代表して初日の月と比較。
        return true
      else
      # 提出済の一ヶ月分の承認申請と勤怠画面の月が一致しない場合は、falseを返答
        return false
      end
    end
  end
  
end
