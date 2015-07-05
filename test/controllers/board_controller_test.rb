require 'test_helper'

class BoardControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
