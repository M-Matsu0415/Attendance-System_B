class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_request_one_month_change, :request_one_month_change, :edit_approval_one_month_change, 
                                  :edit_approval_overwork]
  before_action :logged_in_user, only: [:update, :edit_request_one_month_change]
  before_action :admin_or_correct_user, only: [:update, :edit_request_one_month_change, :request_one_month_change]
  before_action :set_one_month, only: :edit_request_one_month_change
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  # 勤怠登録失敗した場合のエラーコメントを定数として定義

  # 出社時/退社時の勤怠登録  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      # 出勤時間が登録されていない場合にif内の処理実行。
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        # 秒のデータはゼロに変更する。
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れさまでした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  # 勤怠編集画面  
  def edit_request_one_month_change
    if current_user.superior == true
      @users = User.where(superior: true).where.not(id: current_user.id)
    else
      @users = User.where(superior: true)
    end
  end

  # 申請ユーザーからの勤怠変更申請  
  def request_one_month_change
    ActiveRecord::Base.transaction do # トランザクションを開始する。
      attendances_one_month_or_overwork_params.each do |id, item|
        attendance = Attendance.find(id)
        
        if item[:change_approval_superior_id].present? && item[:change_approval_status] == "1"
          # 出勤時間、もしくは退勤時間のみが入っている時には登録できないようにします。
          if item[:started_at_after_approval].present? && item[:finished_at_after_approval].blank? &&
            Date.current != attendance.worked_on
              flash[:danger] = "退社時間も入力してください"
              redirect_to user_url(date: params[:date]) and return
          elsif item[:started_at_after_approval].blank? && item[:finished_at_after_approval].present? &&
            Date.current != attendance.worked_on
              flash[:danger] = "出社時間も入力してください"
              redirect_to user_url(date: params[:date]) and return
          end
          attendance.update_attributes!(item)
          # !を付けることにより更新処理が失敗した場合にfalseを返すのではなく、例外処理を返す。
        end
      end
      flash[:success] = "勤怠変更を申請しました"
      redirect_to user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました" 
    redirect_to user_url(date: params[:date])
  end
  
  # 上長ユーザーの勤怠変更承認画面  
  def edit_approval_one_month_change
    @attendances = Attendance.where(change_approval_superior_id: @user.id, change_approval_status: 1).group_by{|attendance_data| [attendance_data[:user_id]]}
  end
  
  # 上長ユーザーからの勤怠変更承認処理 
  def approval_one_month_change
    a = 0 # approval_status = 1(申請中)の件数(ローカル変数a)に初期値0を代入
    b = 0 # approval_status = 2(承認)の件数(ローカル変数b)に初期値0を代入
    c = 0 # approval_status = 3(否認)の件数(ローカル変数c)に初期値0を代入
    d = 0 # approval_status = 4(なし)の件数(ローカル変数d)に初期値0を代入
    current_user_id = current_user.id
    @user = User.find(current_user_id)
    ActiveRecord::Base.transaction do
    # トランザクションを開始します。
      attendances_one_month_or_overwork_params.each do |id, item|
        attendance = Attendance.find(id)
          if item["change_ok"] == "1"
            attendance_log = AttendanceLog.find_by(worked_on_log: attendance.worked_on)
              if attendance_log.nil?
                store_started_at_for_log = attendance.started_at
                store_finished_at_for_log = attendance.finished_at
              end
            attendance.update_attributes!(item)
            
              if attendance.change_approval_status == 1
                a += 1
              elsif attendance.change_approval_status == 2
                b += 1
              elsif attendance.change_approval_status == 3
                c += 1
              else
                d += 1
              end
              
              #  勤怠変更ログ生成/更新
              final_change_approval_superior_id = attendance.change_approval_superior_id
              final_change_approval_superior = User.find(final_change_approval_superior_id)
              final_change_approval_superior_name = final_change_approval_superior.name
              
                if attendance_log.nil?
                  AttendanceLog.create!(worked_on_log: attendance.worked_on, started_at_log_before_change: store_started_at_for_log, 
                                       finished_at_log_before_change: store_finished_at_for_log, started_at_log_after_change: attendance.started_at, 
                                       finished_at_log_after_change: attendance.finished_at, approval_superior_name: final_change_approval_superior_name, 
                                       approval_date: attendance.updated_at, user_id: attendance.user_id)
                else
                  attendance_log.update_attributes!(started_at_log_after_change: attendance.started_at, finished_at_log_after_change: attendance.finished_at, 
                                                   approval_superior_name: final_change_approval_superior_name, approval_date: attendance.updated_at)
                end
          end
      end
    end
      flash[:success] = "勤怠変更申請のうち申請中を#{a}件、承認を#{b}件、否認を#{c}件、変更なしを#{d}件送信しました"
      redirect_to user_url @user
  rescue ActiveRecord::RecordInvalid
  # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました"
    redirect_to @user
  end
  
  # 申請ユーザーの残業申請モーダル画面  
  def edit_request_overwork
    @attendance = Attendance.find(params[:id])
    if current_user.superior == true
      @users = User.where(superior: true).where.not(id: current_user.id)
    else
      @users = User.where(superior: true)
    end
  end
  
  # 申請ユーザーからの残業申請処理  
  def request_overwork
    attendance = Attendance.find(params[:id])
    @user = User.find(attendance.user_id)
    
      if attendance.update_attributes!(attendances_overwork_params)
        flash[:info] = "残業申請を送信しました"
        attendance_overwork_month_first_day = Attendance.find_by(worked_on: attendance.worked_on.beginning_of_month)
        overwork_month_first_day = attendance_overwork_month_first_day.worked_on
        redirect_to user_url(@user, date: overwork_month_first_day)
      else
        flash[:danger] = "残業申請に失敗しました"
          redirect_to user_url(@user, date: attendance.worked_on.beginning_of_month)
      end
  rescue ActiveRecord::RecordInvalid
  # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました<br>" + 
                     attendance.errors.full_messages.join("<br>")
      redirect_to user_url(@user, date: attendance.worked_on.beginning_of_month)
  end
  
  # 上長ユーザーの残業承認モーダル画面  
  def edit_approval_overwork
    @attendances = Attendance.where(overwork_approval_superior_id: @user.id, overwork_approval_status: 1).group_by{|attendance_data| [attendance_data[:user_id]]}
  end
  
  # 上長ユーザーの残業承認処理  
  def approval_overwork
    a = 0 # approval_status = 1(申請中)の件数(ローカル変数a)に初期値0を代入
    b = 0 # approval_status = 2(承認)の件数(ローカル変数b)に初期値0を代入
    c = 0 # approval_status = 3(否認)の件数(ローカル変数c)に初期値0を代入
    d = 0 # approval_status = 4(なし)の件数(ローカル変数d)に初期値0を代入
    current_user_id = current_user.id
    @user = User.find(current_user_id)
    ActiveRecord::Base.transaction do
    # トランザクションを開始します。
      attendances_one_month_or_overwork_params.each do |id, item|
        attendance = Attendance.find(id)
          if item["change_ok"] == "1"
            attendance.update_attributes!(item)
            
              if attendance.overwork_approval_status == 1
                a += 1
                
              elsif attendance.overwork_approval_status == 2
                b += 1
                
              elsif attendance.overwork_approval_status == 3
                c += 1
                
              else
                d += 1
                
              end
          end
      end
    end
      flash[:success] = "残業申請のうち申請中を#{a}件、承認を#{b}件、否認を#{c}件、変更なしを#{d}件送信しました。"
        redirect_to user_url @user
  rescue ActiveRecord::RecordInvalid
  # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to @user
  end
  
  private

    # 1ヶ月分の勤怠変更情報を扱います。
    def attendances_one_month_or_overwork_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :started_at_after_approval, :finished_at_after_approval, 
      :change_approval_superior_id, :change_approval_status, :note, :overwork_finished_at, :overwork_approval_superior_id, 
      :overwork_approval_status, :overwork_content, :change_next_day_check, :overwork_next_day_check, :change_ok])[:attendances]
    end
    
    def attendances_overwork_params
      params.require(:attendance).permit(:overwork_finished_at, :overwork_approval_superior_id, 
      :overwork_content, :overwork_approval_status, :overwork_next_day_check, :change_ok)
    end
    
end
