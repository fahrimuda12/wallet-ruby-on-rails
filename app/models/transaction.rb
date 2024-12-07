class Transaction < ApplicationRecord
    belongs_to :source_wallet, class_name: 'Wallet', optional: true
    belongs_to :target_wallet, class_name: 'Wallet', optional: true
  
    validates :amount, numericality: { greater_than: 0 }
    validates :transaction_type, inclusion: { in: %w[credit debit] }
  
    validate :validate_transaction, :on => :create

    # before_create :validate_transaction
    after_create :update_wallet_balances
  
    private
  
    def validate_transaction
      # if transaction_type == 'credit' && source_wallet_id.present?
      #   errors.add(:source_wallet, 'should be nil for credit transactions')
      # elsif transaction_type == 'debit' && target_wallet_id.present?
      #   errors.add(:target_wallet, 'should be nil for debit transactions')
      # end
  
      if transaction_type == 'credit' && source_wallet.balance < amount
        errors.add(:target_wallet, 'insufficient balance for credit transaction')
      end
    end
  
    def update_wallet_balances
      if transaction_type == 'credit'
        target_wallet.update!(balance: target_wallet.balance + amount)
      elsif transaction_type == 'debit'
        source_wallet.update!(balance: source_wallet.balance - amount)
      end
    end
  end
  