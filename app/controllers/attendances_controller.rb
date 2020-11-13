class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :request_one_month_change]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :request_one_month_change]
  before_action :set_one_month, only: :edit_one_month
  
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
  def edit_one_month
    @users = User.where(superior: true)
  end

# 申請ユーザーからの勤怠変更申請  
  def request_one_month_change
    ActiveRecord::Base.transaction do # トランザクションを開始する。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        
        if item[:change_approval_superior_id].present? && item[:change_approval_status] == "1"
          
          # 出勤時間、もしくは退勤時間のみが入っている時には登録できないようにします。
          if item[:started_at_after_approval].present? && item[:finished_at_after_approval].blank? &&
            Date.current != attendance.worked_on
          flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end

          attendance.update_attributes!(item)
          # !を付けることにより更新処理が失敗した場合にfalseを返すのではなく、例外処理を返す。
        end
      end
    end
    flash[:success] = "勤怠変更を申請しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐
    flash[:danger] = "無効な入力データがあった為、更新をキャンセル。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :started_at_after_approval, 
      :finished_at_after_approval, :change_approval_superior_id, :change_approval_status, :note, :next])[:attendances]
    end
    
end
