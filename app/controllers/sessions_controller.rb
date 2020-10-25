class SessionsController < ApplicationController

  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # 有効なオブジェクトが取得できている(user：左辺がnilでない)、且つ　authenticateメソッドにより
      # パスワードの認証に成功した場合(右辺がtrue)の場合にif文の条件分岐が成立する。
      log_in user
      params[:session][:remember_me] == '1'? remember(user) : forget(user)
      flash[:success] = "ログインしました。"
      if user.admin?
        redirect_back_or root_url
      else
        redirect_back_or user
      # redirect_back_orの引数にuserを指定することでデフォルトのurlを指定している。
      # userは、user_urlの略、ルーティングはusers#showなので、showアクションが働き、勤怠情報画面に遷移する)
      end
    else
      flash.now[:danger] = "認証に失敗しました。"
      render  :new
    end
  end
  
  def destroy
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in?
    flash[:success] = "ログアウトしました。"
    redirect_to root_url
  end

end
