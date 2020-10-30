class MonthApprovalsController < ApplicationController
  # before_action :set_user, only: :create
  # before_action :set_one_month, only: :create
  
  def new
  end
  
  def create
    @month_approval = MonthApproval.new(month_approval_params)
    
    if @month_approval.save
      flash[:success] = "承認申請しました。"
      @user = User.find(params[:applicant_user_id])
      redirect_to @user
    else
      render  :new
    end
  end
  
  private
    def month_approval_params
      params.permit(:applicant_user_id, :approval_superior_id, :approval_status, :approval_month)
    end
end
