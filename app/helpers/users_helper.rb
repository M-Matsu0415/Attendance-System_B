module UsersHelper
  
  # 勤怠基本情報を指定のフォーマットで返します。  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
    # %は数値によって変化し、.2fは値がない場合は.00、値がある場合はそのまま、小数点第三位以上まである場合は第二位まで表示しそれ以降は切り捨てます。
    # formatメソッドの基本形　format("%.f", 数値)：数値をfで指示された桁数に揃えて文字列で返す-->
  end
  
  # def search_working_members
  #   each.@users do |working_member|
      
  # end
  
end
