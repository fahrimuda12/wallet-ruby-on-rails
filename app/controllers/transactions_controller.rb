class TransactionsController < ApplicationController
  
  include ResponseHelper, AuthorizeRequest 

  def index
    
    if params[:source_wallet_id].blank?
      return error_response(message: 'Source wallet ID must be provided', errors: [], status: :bad_request)
    end
    
    @transactions = Transaction.where(source_wallet_id: params[:source_wallet_id], transaction_type: 'credit')
    .or(Transaction.where(target_wallet_id: params[:source_wallet_id], transaction_type: 'debit'))
    .order(created_at: :desc)
    if params[:transaction_type] == 'credit'
      @transactions = @transactions.where(source_wallet_id: params[:source_wallet_id])
    elsif params[:transaction_type] == 'debit'
      @transactions = @transactions.where(target_wallet_id: params[:source_wallet_id])
    end
    if @transactions.empty?
      return error_response(message: 'No transactions found', errors: [], status: :not_found)
    end

    transactions = @transactions.map do |transaction|
      {
        id: transaction.id,
        source_wallet_id: transaction.source_wallet_id,
        source_wallet_name: transaction.source_wallet.name,
        target_wallet_id: transaction.target_wallet_id,
        target_wallet_name: transaction.target_wallet.name,
        amount: transaction.amount,
        transaction_type: transaction.transaction_type,
        created_at: transaction.created_at,
        updated_at: transaction.updated_at
      }
    end

    success_response(message: 'Success', data: transactions)
  end


  def create
      tag_name = transaction_params[:tag_name]
      virtual_account = transaction_params[:virtual_account]
      target_wallet_id = transaction_params[:target_wallet]
      source_wallet_id = transaction_params[:source_wallet_id]
      transaction_type = transaction_params[:transaction_type]
      amount = transaction_params[:amount]
      # convert amount to numeric
      user_id = current_user.id

      unless Wallet.exists?(id: source_wallet_id, user_id: user_id)
        return error_response(message: 'Source wallet does not belong to the current user', errors: [], status: :forbidden)
      end

      @source_wallet = Wallet.find(source_wallet_id)

      case transaction_type
      when 'deposit'
        handle_transaction { deposit(@source_wallet, amount) }
      when 'withdraw'
        handle_transaction { withdraw(@source_wallet, amount) }
      when 'transfer'

        # cek apakah target wallet id ditemukan
        unless tag_name.nil?
          @target_wallet = Wallet.find_by(tag_name: tag_name)
        end

        unless virtual_account.nil?
          @target_wallet = Wallet.find_by(virtual_account: virtual_account)
        end

          unless target_wallet_id.nil?
            unless Wallet.exists?(id: target_wallet)
              return error_response(message: 'Target wallet not found', errors: [], status: :not_found)
            end
            @target_wallet = Wallet.find(target_wallet_id)
        end

        # cek jika target_wallet tidak ditemukan
        if @target_wallet.nil?
          return error_response(message: 'Target wallet not found', errors: [], status: :not_found)
        end

        handle_transaction { transfer(@source_wallet,  @target_wallet, amount) }
      else
        return error_response(message: 'Invalid transaction type', errors: [], status: :unprocessable_entity)
      end
  end

  private

  # Atomic handler for all transaction operations
  def handle_transaction
    ActiveRecord::Base.transaction do
      yield
    end
    transaction = {
          id: @transaction.id,
          source_wallet_id: @transaction.source_wallet_id,
          source_wallet_name: @transaction.source_wallet.name,
          target_wallet_id: @transaction.target_wallet_id,
          target_wallet_name: @transaction.target_wallet.name,
          amount: @transaction.amount,
          transaction_type: @type,
          created_at: @transaction.created_at,
          updated_at: @transaction.updated_at
        }
    success_response(message: 'Transaction completed', data: transaction)
    # success_response(message: 'Transaction successful')
  rescue ActiveRecord::RecordInvalid => e
    server_error_response(message: 'Record invalid', errors: e.message)
  rescue StandardError => e
    server_error_response(message: 'Exception', errors: e.message)
  end

  # Deposit money into a wallet
  def deposit(wallet, amount)
    wallet.increment!(:balance, amount)
    Transaction.create!(
      wallet_id: wallet.id,
      amount: amount,
      transaction_type: 'deposit'
    )
  end

  # Withdraw money from a wallet
  def withdraw(wallet, amount)
    if wallet.balance < amount
      raise ActiveRecord::RecordInvalid, 'Insufficient balance'
    end

    wallet.decrement!(:balance, amount)
    Transaction.create!(
      wallet_id: wallet.id,
      amount: -amount,
      transaction_type: 'withdraw'
    )
  end

  # Transfer money between wallets
  def transfer(source_wallet, target_wallet, amount)
    # credit
    params_transaction = {
      :source_wallet => @source_wallet,
      :target_wallet => @target_wallet,
      :amount => amount,
      :transaction_type => 'credit'
    }
    
    @transaction = Transaction.create!(params_transaction)
    
    # debit
    params_transaction = {
      :source_wallet => @source_wallet,
      :target_wallet => @target_wallet,
      :amount => amount,
      :transaction_type => 'debit'
    }
    Transaction.create!(params_transaction)

    return { transaction: @transaction, type: 'transfer' }
  end
  
  def history_params
    params.require(:transaction).permit(:source_wallet_id)
  end

  def transaction_params
    params.permit(:source_wallet_id, :target_wallet_id, :amount, :transaction_type, :tag_name, :virtual_account)
  end

end
