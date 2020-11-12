class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper  # sessionsヘルパーが使用できるように宣言
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  # $にてグローバル変数を定義。リテラル表記にて配列["日", "月", "火", "水", "木", "金", "土"]と同等。
  # %w[ ]：スペース区切りの文字列を二重引用符” ”で囲まれた語の配列にする。
  
  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
    # @user_basic_info = User.find(1)
  end
    
  # beforeフィルター
  #store_locationにてsession[:forwarding_url]に現在のurlを記憶
  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください"
      redirect_to login_url
    end
  end
    
  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
    
  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
  
  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
# ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    # params[:date]は、勤怠表示を開いたときにview(users/show.html.erb)から送られるデータのこと。
    # 勤怠表示は、開いた瞬間は今現在の月の勤怠を表示するので、開いた他時にはcurrentメソッドで現在月の初日を取得する。
    # 勤怠表示にて翌月への切り替え(⇒ボタン)、前月への切り替え(⇐ボタン)が押されたら取得済みの現在月を基準に判断され
    # 翌月 or 前月の初日のデータがparams[:date]として送信される。
    # フォーマットは、ja.ymlで指定されている、middle：年/月となる。
    # params[:date]がnilであれば、Date.current.beginning_of_monthをインスタンス変数に代入。nilでなければ
    # params[:date]をDate型に変換したものを代入する。
    # to_date：Time型からDate型に変換できる。
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] 
    # 対象の月の日数(配列データ)を代入します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    
    unless one_month.count == @attendances.count 
    # それぞれの件数（日数）が一致するか評価します。データがないかもしれないために確認の意味で行う。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # トランザクション：指定したブロックにあるデータベースの操作が全部成功することを保証するための機能。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        # worked_onに日付の入ったAttendanceモデルのデータが生成される。
        # create!：最後に!を付けることで保存できない場合例外ActiveRecord::RecordInvalidが発生する。
        # トランザクションは例外が発生した場合にロールバックされる。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
    
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  
  def set_month_approval
    @month_approval = MonthApproval.find_by(user_id: params[:id], approval_superior_id: current_user.id)
  end
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def get_one_month
    @month_approval = MonthApproval.find(params[:id])
    applicant_user_id = @month_approval.user_id
    @user = User.find(applicant_user_id)
      @first_day = @month_approval.approval_month
      @last_day = @first_day.end_of_month
        one_month = [*@first_day..@last_day] 
        # 対象の月の日数(配列データ)を代入します。
        @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
        # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
        
    unless one_month.count == @attendances.count 
    # それぞれの件数（日数）が一致するか評価します。データがないかもしれないために確認の意味で行う。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # トランザクション：指定したブロックにあるデータベースの操作が全部成功することを保証するための機能。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        # worked_onに日付の入ったAttendanceモデルのデータが生成される。
        # create!：最後に!を付けることで保存できない場合例外ActiveRecord::RecordInvalidが発生する。
        # トランザクションは例外が発生した場合にロールバックされる。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
    
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end

end
