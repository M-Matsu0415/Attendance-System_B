class AddBasicInfoToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_time, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
    add_column :users, :work_time, :datetime, default: Time.current.change(hour: 7, min: 30, sec: 0)
    # Time.current：currentメソッドはRailsアプリ独自のメソッドでTimeWithZoneクラスを使用し、config/application.rbに設定してあるタイムゾーンを元に現在日時を取得
    # changeメソッドにてTimeオブジェクトの"hour"、"mini"、"sec"を変更している。
  end
end
