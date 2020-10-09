class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_or_correct_user, only: :show
  before_action :admin_user, only: :destroy
  before_action :set_one_month, only: :show
  

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
    @user.destroy # destroyなのでuserに関わる関連データ(attendance)も削除される。
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def import
    User.import(params[:file])
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
    @user = User.all
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end
end
