module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
    # %は数値によって変化し、.2fは値がない場合は.00、値がある場合はそのまま、小数点第三位以上まである場合は第二位まで表示しそれ以降は切り捨てます。
    # formatメソッドの基本形　format("%.f", 数値)：数値をfで指示された桁数に揃えて返す-->
  end
end
