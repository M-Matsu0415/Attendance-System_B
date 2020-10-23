require 'csv'

CSV.generate(encoding: Encoding::SJIS) do |csv|

  column_names = %w(日付 出勤時間 退勤時間)
  
  csv << column_names
  
  @attendances.each do |attendance|
  
    if !attendance.started_at.nil?
      started_at_csv = attendance.started_at.strftime("%H：%M")
    end
    
    if !attendance.finished_at.nil?
      finished_at_csv = attendance.started_at.strftime("%H：%M")
    end
    
    column_values = [
      attendance.worked_on,
      started_at_csv,
      finished_at_csv
      ]
    csv << column_values
  end
end