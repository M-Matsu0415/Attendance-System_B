module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。if分は条件式の結果がfalseなら何も実行しない。
    # 従ってエラー等にはならず、ボタン自体が表示されないこととなる。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish, next_day_check)
    if next_day_check == true
       format("%.2f", ((((finish - start) / 60) / 60.0) + 24.00))
    else
      format("%.2f", (((finish - start) / 60) / 60.0))
      # %は数値によって変化し、.2fは値がない場合は.00、値がある場合はそのまま、小数点第三位以上まである場合は第二位まで表示しそれ以降は切り捨てます。
      # formatメソッドの基本形　format("%.f", 数値)：数値をfで指示された桁数に揃えて返す
      # finish、startは秒数として取得されるため、60で割って分単位、更に60で割って時間単位となる。
    end
  end
  
  def working_times_display(start, finish)
    format("%.2f", (finish - start))
    # %は数値によって変化し、.2fは値がない場合は.00、値がある場合はそのまま、小数点第三位以上まである場合は第二位まで表示しそれ以降は切り捨てます。
    # formatメソッドの基本形　format("%.f", 数値)：数値をfで指示された桁数に揃えて返す
  end
  
  def started_at_min_or_finished_at_min(start_or_finish_time)
    if start_or_finish_time < 15
      return 0
    elsif 15 <= start_or_finish_time && start_or_finish_time < 30
      return 15
    elsif 30 <= start_or_finish_time && start_or_finish_time < 45
      return 30
    elsif 45 <= start_or_finish_time && start_or_finish_time <= 59
      return 45
    end
  end
  
  def started_at_min_f(started)
    format("%.2f", ((started)/60.00))
  end
  
  def finished_at_min_f(finished)
    format("%.2f", ((finished)/60.00))
  end
  
  # 勤怠変更申請の上長承認状況(勤怠表示画面に表示)
  def change_one_month_superior_check_status(attendance)
    superior_id = attendance.change_approval_superior_id
    if superior_id.present?
      superior = User.find(superior_id)
        if attendance.change_approval_status == 1
          return "#{superior.name}へ変更申請中"
        elsif attendance.change_approval_status == 2
          return "#{superior.name}より変更承認済"
        elsif attendance.change_approval_status == 3
          return "#{superior.name}より変更否認済"
        end
    end
  end
  
  # 残業申請の上長承認状況(勤怠表示画面に表示)
  def overwork_superior_check_status(attendance)
    superior_id = attendance.overwork_approval_superior_id
    if superior_id.present?
      superior = User.find(superior_id)
        if attendance.overwork_approval_status == 1
          return "#{superior.name}へ残業申請中"
        elsif attendance.overwork_approval_status == 2
          return "#{superior.name}より残業承認済"
        elsif attendance.overwork_approval_status == 3
          return "#{superior.name}より残業否認済"
        end
    end
  end
  
  # 上長ユーザーが自分宛てに来ている勤怠変更承認申請の数をカウント
  # 上長の勤怠画面の勤怠変更承認申請のお知らせ表示に使用
  # ユーザー削除機能実行時に削除されるユーザーが上長であるか否か判断するためにまずカウントする。
  def change_approval_count(superior_id)
    if Attendance.where(change_approval_superior_id: superior_id, change_approval_status: 1).present?
      change_approvals = Attendance.where(change_approval_superior_id: superior_id, change_approval_status: 1)
      return change_approvals.count
    else
      return 0
    end
  end
  
  # 上長ユーザーが自分宛てに来ている残業承認申請の数をカウント
  # 上長の勤怠画面の残業承認申請のお知らせ表示に使用
  # ユーザー削除機能実行時に削除されるユーザーが上長であるか否か判断するためにまずカウントする。
  def overwork_approval_count(superior_id)
    if Attendance.where(overwork_approval_superior_id: superior_id, overwork_approval_status: 1).present?
      overwork_approvals = Attendance.where(overwork_approval_superior_id: superior_id, overwork_approval_status: 1)
      return overwork_approvals.count
    else
      return 0
    end
  end
  
  # 上長ユーザーが自分宛てに来ている残業承認申請モーダルを開いたときに表示する時間外時間
  def overtime_calculation(attendance, user)
    overwork_start_time = user.designated_work_end_time.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: attendance.worked_on.day)
    overwork_end_time = attendance.overwork_finished_at.change(year: attendance.worked_on.year, month: attendance.worked_on.month, day: attendance.worked_on.day)
    if attendance.overwork_next_day_check == true
      format("%.2f", ((((overwork_end_time - overwork_start_time) / 60) / 60.0) + 24.00))
    else
      format("%.2f", ((overwork_end_time - overwork_start_time) / 60) / 60.0)
    end
  end
end
