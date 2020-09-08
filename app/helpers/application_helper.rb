module ApplicationHelper
  
  def full_title(page_name = "") #ページ名称を文字列で指定
    base_title = "AttendanceApp"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end
end
