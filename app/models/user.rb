class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :affiliation, length: { in: 2..30 }, allow_blank: true
  validates :basic_time, presence: true
  validates :work_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :employee_number, numericality: true, length: { maximum: 5 }
  
  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    # update_attribute(ハッシュ：name(remember_digest)に対してvalue(User.digest(remember_token))の組み合わせ)
    # validation なしに更新できるので注意が必要。
  end
  
  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
    #  レシーバ::メソッド (定数の場合もあり)という形をとる二重コロン記法
  end
  
  # ユーザーのログイン情報を破棄します。
  def forget
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    update_attribute(:remember_digest, nil)
    # update_attribute(ハッシュ：name(remember_digest)に対してvalue(User.digest(remember_token))の組み合わせ)
    # validation なしに更新できるので注意が必要。
  end
  
  def self.search(search) #ここでのself.はUser.を意味する
    if search
      where(['name LIKE ?', "%#{search}%"]) #検索とnameの部分一致を表示。User.は省略
      # @index_page_title = "検索結果"　←　ここに入れてはダメ。なんで？？
    else
      all #全て表示。User.は省略
      # @index_page_title = "全てのユーザー"　←　ここに入れてはダメ。なんで？？
    end
  end
  
  #importメソッド
  def self.import(file)
    CSV.foreach(file.path, encoding: "CP932:UTF-8", headers: true) do |row|
    # IDが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
      user = new
      # CSVからデータを取得し、設定する
      user.attributes = row.to_hash.slice(*updatable_attributes)
        if !user.save
          flash[:danger] = "csvファイルのデータに問題があります。"
          redirect_to users_url
        end
    end
  end
  
  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid", "basic_time", "designated_work_start_time", "designated_work_end_time",
     "superior", "admin", "password"]
  end
  
  # csv outputメソッド
  require 'csv'
  
  def self.csv_attributes
    [ "worked_on", "started_at", "finished_at" ]
  end
  
  def self.generate_csv
    CSV.generate(headers: true, encoding: Encoding::SJIS) do |csv|
      csv << csv_attributes
      all.each do |part|
        csv << csv_attributes.map{|attr| part.send(attr)}
      end
    end
  end

end
