require 'test_helper'

class MonthApprpvalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get month_apprpvals_new_url
    assert_response :success
  end

end
