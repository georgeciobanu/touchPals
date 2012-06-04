require 'test_helper'

class PurchaseReceiptsControllerTest < ActionController::TestCase
  setup do
    @purchase_receipt = purchase_receipts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_receipts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_receipt" do
    assert_difference('PurchaseReceipt.count') do
      post :create, purchase_receipt: { receipt: @purchase_receipt.receipt, user_id: @purchase_receipt.user_id }
    end

    assert_redirected_to purchase_receipt_path(assigns(:purchase_receipt))
  end

  test "should show purchase_receipt" do
    get :show, id: @purchase_receipt
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_receipt
    assert_response :success
  end

  test "should update purchase_receipt" do
    put :update, id: @purchase_receipt, purchase_receipt: { receipt: @purchase_receipt.receipt, user_id: @purchase_receipt.user_id }
    assert_redirected_to purchase_receipt_path(assigns(:purchase_receipt))
  end

  test "should destroy purchase_receipt" do
    assert_difference('PurchaseReceipt.count', -1) do
      delete :destroy, id: @purchase_receipt
    end

    assert_redirected_to purchase_receipts_path
  end
end
