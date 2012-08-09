require 'test_helper'

class ProcessedDataControllerTest < ActionController::TestCase
  setup do
    @processed_datum = processed_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:processed_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create processed_datum" do
    assert_difference('ProcessedDatum.count') do
      post :create, processed_datum: { capture_date: @processed_datum.capture_date }
    end

    assert_redirected_to processed_datum_path(assigns(:processed_datum))
  end

  test "should show processed_datum" do
    get :show, id: @processed_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @processed_datum
    assert_response :success
  end

  test "should update processed_datum" do
    put :update, id: @processed_datum, processed_datum: { capture_date: @processed_datum.capture_date }
    assert_redirected_to processed_datum_path(assigns(:processed_datum))
  end

  test "should destroy processed_datum" do
    assert_difference('ProcessedDatum.count', -1) do
      delete :destroy, id: @processed_datum
    end

    assert_redirected_to processed_data_path
  end
end
