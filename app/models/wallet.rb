class Wallet < ApplicationRecord
    has_many :incoming_transactions, class_name: 'Transaction', foreign_key: :target_wallet_id
    has_many :outgoing_transactions, class_name: 'Transaction', foreign_key: :source_wallet_id
    has_many :transactions, foreign_key: :source_wallet_id

    validates :type, :balance, presence: true
    validates :key_phrases, presence: true
    validate :key_phrases_length
    validates :virtual_account, presence: true,uniqueness: true
    validates :tag_name, presence: true, uniqueness: true 

    before_validation :generate_key_phrases, :generate_virtual_account, :generate_tag_name, on: :create

    private

    # Validasi jumlah key phrases
    def key_phrases_length
      errors.add(:key_phrases, 'must contain exactly 16 words') if key_phrases.size != 16
    end
  
    # Generate 16 random key phrases
    def generate_key_phrases
      self.key_phrases = Array.new(16) { SecureRandom.alphanumeric(8) } if key_phrases.empty?
    end

    def generate_virtual_account
      self.virtual_account = "0023" + SecureRandom.random_number(10**8).to_s.rjust(8, '0')
    end

    def generate_tag_name
      self.tag_name = "#{name}_#{SecureRandom.alphanumeric(2)}"
    end

end
