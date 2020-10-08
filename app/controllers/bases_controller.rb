class BasesController < ApplicationController

  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点追加に成功しました"
      redirect_to bases_path
    else
      render  :new
    end
  end
  
  def index
    @bases = Base.all
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.name}のデータを削除しました。"
    redirect_to bases_url
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました"
      redirect_to bases_url
    else
      render :edit
    end
  end
  
  private

    def base_params
      params.require(:base).permit(:name, :number, :status)
    end

end
