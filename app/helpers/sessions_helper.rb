module SessionsHelper
  
  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # 永続的セッションを記憶します（Userモデルを参照)
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id #ユーザーIDをcookiesに保存する。signed:安全性確保のため必要。permanent:永続化
    cookies.permanent[:remember_token] = user.remember_token #永続的セッション作成
  end
  
  # 永続的セッションを破棄します
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # セッションと@current_userを破棄します
  def log_out
    if logged_in?
      forget(current_user) #フォーゲットメソッド呼び出し
      session.delete(:user_id)
      @current_user = nil
    end
  end
  
  # 現在ログイン中のユーザーがいる場合オブジェクトを返します。
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
  
  # 渡されたユーザーがログイン済みのユーザーであればtrueを返します。
  def current_user?(user)
    user == current_user
  end
  
  # 現在ログイン中のユーザーがいれば(current_userがnilでない)true、そうでなければ(current_userがnil)falseを返します。
  def logged_in?
    !current_user.nil?
  end
end
