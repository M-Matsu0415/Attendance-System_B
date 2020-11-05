class MonthApprovalsController < ApplicationController
  before_action :set_user, only: [:edit]
  # before_action :logged_in_user, only: :create
  # before_action :admin_or_correct_user, only: :create
  # before_action :set_one_month, only: :create
  # before_action :set_user, only: :create
  # before_action :set_one_month, only: :create
  
  def new
  end
  
# 一般ユーザーによる一ヶ月分の承認申請
  def create
    current_user_id = current_user.id
    @user = User.find(current_user_id)
    # @user = User.find(params[:user_id])
    @month_approval = MonthApproval.new(month_approval_params)
    
    if @month_approval.save
      flash[:success] = "承認申請しました。"
      redirect_to @user
    else
      flash[:danger] = "承認申請に失敗しました。"
      redirect_to @user
    end
  end

# 上長による一ヶ月の勤怠承認/否認。editアクションで自分宛てに来ている承認申請を全て表示。
  def edit
    @month_approvals = MonthApproval.where(approval_superior_id: @user.id)
  end

# 上長による一ヶ月の勤怠承認/否認。updateアクションで自分宛てに来ている承認申請を更新。
  def update_month_approvals
    current_user_id = current_user.id
    @user = User.find(current_user_id)
    ActiveRecord::Base.transaction do
    # トランザクションを開始します。
      month_approvals_params.each do |id, item|
        month_approval = MonthApproval.find(id)
        month_approval.update_attributes!(item)
      end
    end
      flash[:success] = "1ヶ月分の勤怠申請を更新しました。"
      redirect_to user_url @user
  rescue ActiveRecord::RecordInvalid
  # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  private
  
    def month_approval_params
      params.permit(:applicant_user_id, :approval_superior_id, :approval_status, :approval_month)
    end
    
    def month_approvals_params
      params.require(:month_approval).permit(month_approvals: [:approval_status])[:month_approvals]
    end
    
end
