class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :csv_output, :create_month_approval, :attendance_log_all, :attendance_log_search]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :create_month_approval]
  before_action :correct_user, only: [:edit, :create, :show]
  before_action :admin_or_correct_user, only: [:create_month_approval]
  before_action :admin_user, only: [:destroy, :index, :working_members, :edit_basic_info]
  before_action :set_one_month, only: [:show, :csv_output, :create_month_approval]
  before_action :get_one_month_for_month_approval, only: :reference_month_approval
  before_action :get_one_month_for_change_or_overwork, only: :reference_change_or_overwork
  

  def index
    if current_user.admin?
      @users = User.where.not(id: current_user.id)
    else
      redirect_to root_url
    end
  end
  
  def show
    # 出勤時間が空白でない日数を数え、インスタンス変数(@worked_sum)に代入
    @worked_sum = @attendances.where.not(started_at: nil).count
    
    # 自分自身が上長の場合、申請先として選択できる上長を自分以外に設定する
    if current_user.superior == true
      @users = User.where(superior: true).where.not(id: current_user.id)
    else
      @users = User.where(superior: true)
    end
    
    attendance_data_of_first_day = @attendances.find_by(worked_on: @first_day)
    current_worked_on = attendance_data_of_first_day.worked_on
    @month_approval = MonthApproval.find_by(user_id: @user.id, approval_month: current_worked_on)
    if @month_approval.nil?
      @month_approval = MonthApproval.new
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規作成に成功しました"
        redirect_to @user
    else
      render  :new
    end
  end
  
  def edit
  end
  
  def edit_user_info
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
        redirect_to(@user)
    else
      flash[:danger] = "ユーザー情報の更新に失敗しました<br>" + @user.errors.full_messages.join("<br>")
        redirect_to(root_url)
    end
  end
  
  def update_by_admin
    @user = User.find(user_params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
        redirect_to users_url
    else
      flash[:danger] = "ユーザー情報の更新に失敗しました<br>" + @user.errors.full_messages.join("<br>")
        redirect_to users_url
    end
  end

  def destroy
    # 削除されるユーザーが上長であった場合、該当する一ヶ月分の勤怠申請削除
    if MonthApproval.where(approval_superior_id: params[:id]).present?
      # ユーザー削除機能実行時に削除されるユーザーが申請中の上長であった場合は
      # 申請も削除する必要があるので、削除対象となるリソースがあれば抽出する。
      month_approvals_by_superiors = MonthApproval.where(params[:id])
        ActiveRecord::Base.transaction do
        # トランザクションを開始します。
          month_approvals_by_superiors.each do |superior|
            month_approval_by_superior = MonthApproval.find(superior.id)
            month_approval_by_superior.destroy!
        end
      rescue ActiveRecord::RecordInvalid
      # トランザクションによるエラーの分岐です。
        flash[:danger] = "ユーザーに関連ずる承認データの削除に失敗しました。<br>" + 
                         month_approval_by_superior.errors.full_messages.join("<br>")
        redirect_to @user
      end
    end
    
    # 削除されるユーザーが上長であった場合、該当する勤怠変更申請をnilに変更
    if Attendance.where(change_approval_superior_id: params[:id]).present?
      # ユーザー削除機能実行時に削除されるユーザーが申請中の上長であった場合は
      # 申請も削除する必要があるので、削除対象となるリソースがあれば抽出する。
      change_approvals_by_superiors = Attendance.where(change_approval_superior_id: @user.id)
        ActiveRecord::Base.transaction do
        # トランザクションを開始します。
          change_approvals_by_superiors.each do |change_approval_by_superior|
            change_approval_by_superior.update_attributes!(started_at_after_approval: nil, finished_at_after_approval: nil,
            change_approval_superior_id: nil, change_approval_status: nil, note: nil, change_next_day_check: nil)
        end
      rescue ActiveRecord::RecordInvalid
      # トランザクションによるエラーの分岐です。
        flash[:danger] = "ユーザーに関連ずる承認データの削除に失敗しました。<br>" + 
                         change_approval_by_superior.errors.full_messages.join("<br>")
        redirect_to @user
      end
    end
    
    # 削除されるユーザーが上長であった場合、該当する残業申請をnilに変更
    if Attendance.where(overwork_approval_superior_id: params[:id]).present?
      # ユーザー削除機能実行時に削除されるユーザーが申請中の上長であった場合は
      # 申請も削除する必要があるので、削除対象となるリソースがあれば抽出する。
      overwork_approvals_by_superiors = Attendance.where(overwork_approval_superior_id: @user.id)
        ActiveRecord::Base.transaction do
        # トランザクションを開始します。
          overwork_approvals_by_superiors.each do |overwork_approval_by_superior|
            overwork_approval_by_superior.update_attributes!(overwork_finished_at: nil, overwork_approval_superior_id: nil,
            overwork_content: nil, overwork_approval_status: nil, overwork_next_day_check: nil)
        end
      rescue ActiveRecord::RecordInvalid
      # トランザクションによるエラーの分岐です。
        flash[:danger] = "ユーザーに関連ずる承認データの削除に失敗しました。<br>" + 
                         overwork_approval_by_superior.errors.full_messages.join("<br>")
        redirect_to @user
      end
    end
    
    @user.destroy # destroyなのでuserに関わる関連データ(attendance、month_approval)も削除される。
      flash[:success] = "#{@user.name}のデータを削除しました。"
      redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def import
    if params[:file].nil?
      flash[:danger] = "csvファイルが選択されていません。"
      redirect_to users_url
    else
      CSV.foreach(params[:file].path, encoding: "Shift_JIS:UTF-8", headers: true) do |row|
        user = new
        # CSVからデータを取得し、設定する
        user.attributes = row.to_hash.slice("name", "email", "affiliation", "employee_number", "uid",
                                            "basic_time", "designated_work_start_time", "designated_work_end_time",
                                            "superior", "admin", "password")
        user.save
        if !user.save
          flash[:danger] = "csvファイルのデータに問題があります。"
          redirect_to users_url and return
        end
      end
        flash[:success] = "社員情報をインポートしました"
        redirect_to users_url
    end
  end
  
  require 'csv'
  
  def csv_output
    respond_to do |format|
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
  end
  
  def send_attendances_csv(attendances)
    csv_data = CSV.generate(encoding: Encoding::SJIS) do |csv|
      
      column_names = %w(日付 出勤時間 退勤時間)
      csv << column_names
      
      attendances.each do |attendance|
        if !attendance.started_at.nil?
          started_at_csv = attendance.started_at.strftime("%H：%M")
        end
        
        if !attendance.finished_at.nil?
          finished_at_csv = attendance.finished_at.strftime("%H：%M")
        end
        
        column_values = [ attendance.worked_on, started_at_csv, finished_at_csv ]
        csv << column_values
      end
    end
    send_data(csv_data, filename: "勤怠情報.csv")
  end

  def update_basic_info
    if params[:user][:all_user_change] == "1"
      users = User.all
      ActiveRecord::Base.transaction do # トランザクションを開始する。
      users.each do |user|
        user.update_attributes!(basic_info_params)
      end
        flash[:success] = "全ユーザーの基本情報を更新しました"
    rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐
      flash[:danger] = "基本情報の更新は失敗しました" 
      redirect_to user_url
    end
    else
      if @user.update_attributes(basic_info_params)
        flash[:success] = "#{@user.name}の基本情報を更新しました"
      else
        flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" 
        + @user.errors.full_messages.join("<br>")
      end
    end
      redirect_to users_url
  end
  
  def working_members
    @first_day = Date.current.beginning_of_month
    @last_day = @first_day.end_of_month
    @users = User.all
  end
  
  def reference_month_approval
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  def reference_change_or_overwork
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  # 勤怠変更ログ表示  
  def attendance_log_all
    @attendance_logs = AttendanceLog.where(user_id: @user.id,).order(:worked_on_log)
  end
  
  # 勤怠変更ログ 年/月による絞り込み検索  
  def attendance_log_search
    @search_year = params["year(1i)"].to_i
    # to_iメソッドで文字列を整数に変換する。
    @search_month = params["month(2i)"].to_i
    # to_iメソッドで文字列を整数に変換する。
    searched_first_date = Date.new(@search_year, @search_month, 1)
    # 検索対象の年、および月の初日を生成する。初日は必ず1日なので日にちには固定値”1”を入れる。
    searched_last_date = searched_first_date.end_of_month
    # 検索対象の最終日を生成する。初日を使用して生成する。
    @attendance_logs = AttendanceLog.where(worked_on_log: searched_first_date..searched_last_date).order(:worked_on_log)
    # 生成した月の初日と最終日を使用してwhereメソッドで、AttendanceLogを範囲検索する。
  end
  
  private
    def user_params
      params.require(:user).permit(:id, :name, :email, :employee_number, :uid, :affiliation, :password, 
                                   :basic_time, :designated_work_start_time, :designated_work_end_time, 
                                   :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:designated_work_start_time, :designated_work_end_time, :basic_time, :all_user_change)
    end

end
