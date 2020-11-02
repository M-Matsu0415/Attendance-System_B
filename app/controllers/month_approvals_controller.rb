class MonthApprovalsController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  # before_action :logged_in_user, only: :create
  # before_action :admin_or_correct_user, only: :create
  # before_action :set_one_month, only: :create
  # before_action :set_user, only: :create
  # before_action :set_one_month, only: :create
  
  def new
  end
  
# 一般ユーザーによる一ヶ月分の承認申請
  def create
    @user = User.find(params[:user_id])
    @month_approval = @user.month_approvals.build(month_approval_params)
    
    if @month_approval.save
      flash[:success] = "承認申請しました。"
      redirect_to @user
    else
      flash[:danger] = "承認申請に失敗しました。"
      redirect_to @user
    end
  end

# 上長による一ヶ月の勤怠承認/否認
  def edit
    @month_approvals = MonthApproval.where(approval_superior_id: @user.id)
  end
  
  def update_month_approvals
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      month_approval_params.each do |id, item|
        month_approval = MonthApproval.find(params: [:user_id])
        month_approval.update_attributes!(item)
      end
    end
      flash[:success] = "1ヶ月分の勤怠申請を更新しました。"
      redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  private
  
    def month_approval_params
      params.permit(:user_id, :applicant_user_id, :approval_superior_id, :approval_status, :approval_month)
    end
    
end
