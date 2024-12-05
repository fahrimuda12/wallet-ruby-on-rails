class Wallet < ApplicationRecord
    has_many :incoming_transactions, class_name: 'Transaction', foreign_key: :target_wallet_id
    has_many :outgoing_transactions, class_name: 'Transaction', foreign_key: :source_wallet_id

    validates :entity_type, :entity_id, :balance, presence: true
end
