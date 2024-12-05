class WalletController < ApplicationController
  # require_relative '../resources/wallet/wallet_resources'


  before_action :set_wallet, only: %i[ show update destroy ]

  include ResponseHelper


  # GET /wallets
  def index
    @wallets = Wallet.all
    
    # check not empty
    if @wallets.empty?
      return render json: { message: "No wallets found" }, status: :not_found
    end

    # @wallet = WalletMutation.new(@wallets).transform
    print @wallets
    # @wallets = WalletResources::WalletMutation.new(@wallets).transform 
    # @wallets = @wallets.map { |wallet| WalletResources::WalletMutation.new(wallet).transform }
    
    @wallets = @wallets.map do |wallet|
      {
        id: wallet.id,
        name: wallet.name,
        created_at: wallet.created_at,
        updated_at: wallet.updated_at
      }
    end

    data = {
      message: "Success",
      data: @wallets,
      errors: '',
      code: 200
    }

    render json: data
  end

  # GET /wallets/1
  def show
    render json: @wallet
  end

  # POST /wallets
  def create
    begin
      print params_create

      # check entity type sudah ada atau belum
      if Wallet.exists?(entity_type: params_create[:entity_type], entity_id: params_create[:entity_id])
        return error_response(message: 'Entity already has a wallet', errors: [], status: :conflict)
      end

      @wallet = Wallet.new(params_create)

      Wallet.transaction do
        unless @wallet.save
          raise ActiveRecord::Rollback
          return render json: @wallet.errors, status: :unprocessable_entity
        end
      end

      success_response(message: 'Wallet created successfully', data: @wallet, status: :created)

    rescue ActionController::ParameterMissing => e
      server_errror_response(message: 'Parameter missing', errors: e.message)
    rescue Exception => e
      server_errror_response(message: 'Exception', errors: e.message)
      raise
    end
  end

  # PATCH/PUT /wallets/1
  def update
    if @wallet.update(wallet_params)
      render json: @wallet
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  # DELETE /wallets/1
  def destroy
    @wallet.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find_by(id: params[:id])
      render json: { error: 'Wallet not found' }, status: :not_found if @wallet.nil?
    end

    # Only allow a list of trusted parameters through.
    def wallet_params
      params.require(:wallet).permit(:entity_type, :entity_id, :balance)
    end

    def params_create
      params.require(:wallet).permit(:entity_type, :entity_id, :balance)
    end
end
