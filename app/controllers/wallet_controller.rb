class WalletController < ApplicationController
  # require_relative '../resources/wallet/wallet_resources'


  before_action :set_wallet, only: %i[ show update destroy ]
  # before_action :auhtorize_user

  include ResponseHelper, AuthorizeRequest 


  # GET /wallets
  def index
    @wallets = Wallet.all
    
    # check not empty
    if @wallets.empty?
      return error_response(message: 'No wallets found', errors: [], status: :not_found)
    end

    # @wallet = WalletMutation.new(@wallets).transform
    print @wallets
    # @wallets = WalletResources::WalletMutation.new(@wallets).transform 
    # @wallets = @wallets.map { |wallet| WalletResources::WalletMutation.new(wallet).transform }
    
    @wallets = @wallets.map do |wallet|
      {
        id: wallet.id,
        entity_type: wallet.entity_type,
        balance: wallet.balance,
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
    @wallet = {
      id: @wallet.id,
      entity_type: @wallet.entity_type,
      balance: @wallet.balance,
      created_at: @wallet.created_at,
      updated_at: @wallet.updated_at,
      transactions: @wallet.transactions.map do |transaction|
        {
          id: transaction.id,
          amount: transaction.amount,
          description: transaction.description,
          source_wallet_id: transaction.source_wallet_id,
          target_wallet_id: transaction.target_wallet_id,
          created_at: transaction.created_at,
          updated_at: transaction.updated_at
        }
      end
    }
    success_response(message: 'Wallet found', data: @wallet)
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

   # POST /api/wallets/:id/validate
   def validate_key_phrases
    input_phrases = params[:key_phrases] || []

    if (input_phrases & @wallet.key_phrases).size >= 5
      render_success(message: 'Wallet validated successfully')
    else
      render_error(message: 'Failed to validate wallet', errors: ['Insufficient matching key phrases'])
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
      params.require(:wallet).permit(:entity_type, :entity_id, :balance).merge(user_id: @current_user.id)
      
    end
end
