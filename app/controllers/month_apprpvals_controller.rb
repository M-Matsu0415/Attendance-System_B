class MonthApprpvalsController < ApplicationController
  before_action :set_user, only: :create
  before_action :set_one_month, only: :create
  
  def new
  end
  
  def create
    @month_approval = month_approval.new(month_approval_params)
    @month_approval.applicant_user_id = @user.id
    @month_approval.approval_status = 1
    if @month_approval.save
      flash[:success] = "に成功しました"
      redirect_to @user
    else
      render  :new
    end
  end
  
  private
    def month_approval_params
      params.require(:month_approval).permit(:approval_superior_id)
    end
  
end
