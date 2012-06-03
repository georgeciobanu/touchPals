class PurchaseReceiptsController < ApplicationController
  # GET /purchase_receipts
  # GET /purchase_receipts.json
  def index
    @purchase_receipts = PurchaseReceipt.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @purchase_receipts }
    end
  end

  # GET /purchase_receipts/1
  # GET /purchase_receipts/1.json
  def show
    @purchase_receipt = PurchaseReceipt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @purchase_receipt }
    end
  end

  # GET /purchase_receipts/new
  # GET /purchase_receipts/new.json
  def new
    @purchase_receipt = PurchaseReceipt.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @purchase_receipt }
    end
  end

  # GET /purchase_receipts/1/edit
  def edit
    @purchase_receipt = PurchaseReceipt.find(params[:id])
  end

  # POST /purchase_receipts
  # POST /purchase_receipts.json
  def create
    @purchase_receipt = PurchaseReceipt.new(params[:purchase_receipt])

    respond_to do |format|
      if @purchase_receipt.save
        format.html { redirect_to @purchase_receipt, notice: 'Purchase receipt was successfully created.' }
        format.json { render json: @purchase_receipt, status: :created, location: @purchase_receipt }
      else
        format.html { render action: "new" }
        format.json { render json: @purchase_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /purchase_receipts/1
  # PUT /purchase_receipts/1.json
  def update
    @purchase_receipt = PurchaseReceipt.find(params[:id])

    respond_to do |format|
      if @purchase_receipt.update_attributes(params[:purchase_receipt])
        format.html { redirect_to @purchase_receipt, notice: 'Purchase receipt was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @purchase_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_receipts/1
  # DELETE /purchase_receipts/1.json
  def destroy
    @purchase_receipt = PurchaseReceipt.find(params[:id])
    @purchase_receipt.destroy

    respond_to do |format|
      format.html { redirect_to purchase_receipts_url }
      format.json { head :no_content }
    end
  end
end
