require 'test_helper'

class Sensors::PlatformsControllerTest < ActionController::TestCase
  setup do
    @sensors_platform = sensors_platforms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sensors_platforms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sensors_platform" do
    assert_difference('Sensors::Platform.count') do
      post :create, sensors_platform: @sensors_platform.attributes
    end

    assert_redirected_to sensors_platform_path(assigns(:sensors_platform))
  end

  test "should show sensors_platform" do
    get :show, id: @sensors_platform
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sensors_platform
    assert_response :success
  end

  test "should update sensors_platform" do
    put :update, id: @sensors_platform, sensors_platform: @sensors_platform.attributes
    assert_redirected_to sensors_platform_path(assigns(:sensors_platform))
  end

  test "should destroy sensors_platform" do
    assert_difference('Sensors::Platform.count', -1) do
      delete :destroy, id: @sensors_platform
    end

    assert_redirected_to sensors_platforms_path
  end
end
