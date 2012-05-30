require 'test_helper'

class Sensors::ProcessSensorsControllerTest < ActionController::TestCase
  setup do
    @sensors_process_sensor = sensors_process_sensors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sensors_process_sensors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sensors_process_sensor" do
    assert_difference('Sensors::ProcessSensor.count') do
      post :create, sensors_process_sensor: @sensors_process_sensor.attributes
    end

    assert_redirected_to sensors_process_sensor_path(assigns(:sensors_process_sensor))
  end

  test "should show sensors_process_sensor" do
    get :show, id: @sensors_process_sensor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sensors_process_sensor
    assert_response :success
  end

  test "should update sensors_process_sensor" do
    put :update, id: @sensors_process_sensor, sensors_process_sensor: @sensors_process_sensor.attributes
    assert_redirected_to sensors_process_sensor_path(assigns(:sensors_process_sensor))
  end

  test "should destroy sensors_process_sensor" do
    assert_difference('Sensors::ProcessSensor.count', -1) do
      delete :destroy, id: @sensors_process_sensor
    end

    assert_redirected_to sensors_process_sensors_path
  end
end
