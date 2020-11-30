class MonthApprovalsController < ApplicationController
  before_action :set_user, only: :edit
  before_action :set_one_month, only: :update_month_approval
  before_action :correct_user, only: :edit
  
  def new
  end
  
# 一般ユーザーによる一ヶ月分の承認申請
  def create
    current_user_id = current_user.id
    @user = User.find(current_user_id)
    
    if month_approval_params[:month_approval][:approval_superior_id].blank?
      flash[:danger] = "上長の選択が「なし」になっています。"
        @first_day = month_approval_params[:month_approval][:approval_month]
          redirect_to user_url(@user, date: @first_day)
    
    else
      extract_params = month_approval_params[:month_approval]
      @month_approval = MonthApproval.new(extract_params)
    
      if @month_approval.save
        flash[:success] = "承認申請しました。"
          @first_day = @month_approval.approval_month
            redirect_to user_url(@user, date: @first_day)
          
      else
        flash[:danger] = "承認申請に失敗しました。"
          redirect_to user_url(@user, date: @first_day)
          
      end
    end
  end
  
# 一般ユーザーによる一ヶ月分の承認申請(再申請)
  def update
    current_user_id = current_user.id
    @user = User.find(current_user_id)
    
    if month_approval_params[:month_approval][:approval_superior_id].blank?
      flash[:danger] = "上長の選択が「なし」になっています。"
        @first_day = month_approval_params[:month_approval][:approval_month]
          redirect_to user_url(@user, date: @first_day)
    
    else
      @month_approval = MonthApproval.find(params[:id])
      @month_approval.update_attributes(month_approval_params[:month_approval])
    
      if @month_approval.update_attributes(month_approval_params[:month_approval])
        flash[:success] = "承認申請を再送しました。"
          @first_day = @month_approval.approval_month
            redirect_to user_url(@user, date: @first_day)
      
      else
        flash[:danger] = "承認申請の再送に失敗しました。"
          redirect_to @user
        
      end
    end
  end

# 上長による一ヶ月の勤怠承認/否認。editアクションで自分宛てに来ている承認申請を全て表示。
  def edit
    @month_approvals = MonthApproval.where(approval_superior_id: @user.id, approval_status: 1).order(:approval_month).group_by{|approval_data| [approval_data[:user_id]]}
  end

# 上長による一ヶ月の勤怠承認/否認。updateアクションで自分宛てに来ている承認申請を更新。
  def update_month_approvals
    a = 0 # approval_status = 1(申請中)の件数(ローカル変数a)に初期値0を代入
    b = 0 # approval_status = 2(承認)の件数(ローカル変数b)に初期値0を代入
    c = 0 # approval_status = 3(否認)の件数(ローカル変数c)に初期値0を代入
    d = 0 # approval_status = 4(なし)の件数(ローカル変数d)に初期値0を代入
    current_user_id = current_user.id
    @user = User.find(current_user_id)
    ActiveRecord::Base.transaction do
    # トランザクションを開始します。
      month_approvals_params.each do |id, item|
        month_approval = MonthApproval.find(id)
          if item["change_ok"] == "1"
            month_approval.update_attributes!(item)
            
              if month_approval.approval_status == 1
                a += 1
                
              elsif month_approval.approval_status == 2
                b += 1
                
              elsif month_approval.approval_status == 3
                c += 1
                
              else
                d += 1
                
              end
          end
      end
    end
      flash[:success] = "1ヶ月分の勤怠申請のうち申請中を#{a}件、承認を#{b}件、否認を#{c}件、変更なしを#{d}件送信しました。"
      redirect_to user_url @user
  rescue ActiveRecord::RecordInvalid
  # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  private
  
    def month_approval_params
      params.permit(month_approval:[:id, :user_id, :applicant_user_id, :approval_superior_id, :approval_status, :approval_month])
    end
    
    def month_approvals_params
      params.permit(month_approvals: [:approval_status, :change_ok])[:month_approvals]
    end
    
end
