require 'test_helper'

class Sensors::SensorsControllerTest < ActionController::TestCase
  setup do
    @sensors_sensor = sensors_sensors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sensors_sensors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sensors_sensor" do
    assert_difference('Sensors::Sensor.count') do
      post :create, sensors_sensor: @sensors_sensor.attributes
    end

    assert_redirected_to sensors_sensor_path(assigns(:sensors_sensor))
  end

  test "should show sensors_sensor" do
    get :show, id: @sensors_sensor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sensors_sensor
    assert_response :success
  end

  test "should update sensors_sensor" do
    put :update, id: @sensors_sensor, sensors_sensor: @sensors_sensor.attributes
    assert_redirected_to sensors_sensor_path(assigns(:sensors_sensor))
  end

  test "should destroy sensors_sensor" do
    assert_difference('Sensors::Sensor.count', -1) do
      delete :destroy, id: @sensors_sensor
    end

    assert_redirected_to sensors_sensors_path
  end
end
