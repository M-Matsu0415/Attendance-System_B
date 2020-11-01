class MonthApprovalsController < ApplicationController
  before_action :set_user, only: :edit
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
      flash[:success] = "承認申請に失敗しました。"
      redirect_to @user
    end
  end

# 上長による一ヶ月の勤怠承認/否認
  def edit
    @month_approvals = MonthApproval.where(superior_id: @user.id)
  end
  
  private
  
    def month_approval_params
      params.permit(:user_id, :applicant_user_id, :approval_superior_id, :approval_status, :approval_month)
    end
    
end
