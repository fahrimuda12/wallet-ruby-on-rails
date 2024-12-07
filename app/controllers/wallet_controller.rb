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
        name: wallet.name,
        type: wallet.type,
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
      entity_type: @wallet.type,
      balance: @wallet.balance,
      tag_name: @wallet.tag_name,
      virtual_account: @wallet.virtual_account,
      created_at: @wallet.created_at,
      updated_at: @wallet.updated_at,
      transactions: @wallet.transactions.map do |transaction|
        {
          id: transaction.id,
          amount: transaction.amount,
          source_wallet_id: transaction.source_wallet_id,
          target_wallet_id: transaction.target_wallet_id,
          transaction_type: transaction.transaction_type,
          created_at: transaction.created_at,
          updated_at: transaction.updated_at
        }
      end
    }
    success_response(message: 'Wallet  ', data: @wallet)
  end

  # POST /wallets
  def create
    begin
      p params_create[:entity_type]
      # mutation params
      params_wallet = {
        :balance => params_create[:balance],
        :name => params_create[:name],
        :user_id => params_create[:user_id]
      }
      p params_wallet
      # check entity type sudah ada atau belum
      if Wallet.exists?(type: params_create[:entity_type], user_id: @current_user.id)
        return error_response(message: 'Entity already has a wallet', errors: [], status: :conflict)
      end

      # buat switch case untuk membuat wallet berdasarkan entity type
      case params_create[:entity_type]
      when 'User'
        @wallet = UserWallet.new(params_wallet)
      when 'Team'
        @wallet = TeamWallet.new(params_wallet)
      else
        return error_response(message: 'Invalid entity type', errors: [], status: :unprocessable_entity)
      end


      Wallet.transaction do
        unless @wallet.save
          return error_response(message: 'Failed to create wallet', errors: @wallet.errors, status: :unprocessable_entity)
        end
      end

      success_response(message: 'Wallet created successfully', data: @wallet, status: :created)

    # add rollback
    rescue ActiveRecord::RecordInvalid
      server_error_response(message: 'Record invalid', errors: @wallet.errors)
      raise ActiveRecord::Rollback
    rescue ActionController::ParameterMissing => e
      server_error_response(message: 'Parameter missing', errors: e.message)
    rescue Exception => e
      server_error_response(message: 'Exception', errors: e.message)
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
      params.require(:wallet).permit(:entity_type, :balance)
    end

    def params_create
      params.permit(:entity_type, :balance, :name).merge(user_id: @current_user.id)
    end
end
