class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :csv_output, :create_month_approval, :show_reference]
  before_action :set_month_approval, only: :show_reference
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :create_month_approval]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_or_correct_user, only: [:show, :create_month_approval]
  before_action :admin_user, only: :destroy
  before_action :set_one_month, only: [:show, :csv_output, :create_month_approval]
  before_action :get_one_month, only: :show_reference
  

  def index
    if current_user.admin?
      # searchメソッド(user.rb)を呼び出している。searchがない場合、search(params[:search])は、all(全て)となる。
      @users = User.paginate(page: params[:page]).search(params[:search])
    else
      redirect_to root_url
    end
  end
  
  def show
    # 出勤時間が空白でない日数を数え、インスタンス変数(@worked_sum)に代入
    @worked_sum = @attendances.where.not(started_at: nil).count
    @users = User.where(superior: true)
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
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if MonthApproval.where(approval_superior_id: params[:id]).present?
      # ユーザー削除機能実行時に削除されるユーザーが上長に対する申請も削除する必要があるので
      # 削除対象となるリソースを抽出する。
      month_approvals_by_superiors = MonthApproval.where(params[:id])
        ActiveRecord::Base.transaction do
        # トランザクションを開始します。
          month_approvals_by_superiors.each do |superior|
            month_approval_by_superior = MonthApproval.find(superior.id)
            month_approval_by_superior.destroy!
        end
      rescue ActiveRecord::RecordInvalid
      # トランザクションによるエラーの分岐です。
        flash[:danger] = "ユーザーに関連ずる承認データの削除に失敗しました。"
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
    # if current_user.admin?
    #   User.all.update_all.params[:basic_time][:work_time]
    #   flash[:success] = "全ユーザーの基本情報を更新しました。"
    # elsif
    #   @user.update_attributes(basic_info_params)
    #   flash[:success] = "#{@user.name}の基本情報を更新しました。"
    # else
    #   flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
      # <br>要素は改行

    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の基本情報の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
      # <br>要素は改行
    end
      redirect_to users_url
  end
  
  def working_members
    @first_day = Date.current.beginning_of_month
    @last_day = @first_day.end_of_month
    @users = User.all
  end
  
  def show_reference
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :employee_number, :affiliation, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end

end
