class Wallet < ApplicationRecord
    has_many :incoming_transactions, class_name: 'Transaction', foreign_key: :target_wallet_id
    has_many :outgoing_transactions, class_name: 'Transaction', foreign_key: :source_wallet_id
    has_many :transactions, foreign_key: :source_wallet_id

    validates :entity_type, :entity_id, :balance, presence: true
    validates :key_phrases, presence: true
    validate :key_phrases_length

    before_validation :generate_key_phrases, on: :create

    private

    # Validasi jumlah key phrases
    def key_phrases_length
      errors.add(:key_phrases, 'must contain exactly 16 words') if key_phrases.size != 16
    end
  
    # Generate 16 random key phrases
    def generate_key_phrases
      self.key_phrases = Array.new(16) { SecureRandom.alphanumeric(8) } if key_phrases.empty?
    end

end
