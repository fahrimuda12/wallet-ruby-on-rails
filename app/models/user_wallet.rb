class UserWallet < Wallet
  validates :user_id, uniqueness: true
end
