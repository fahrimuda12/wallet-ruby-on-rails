class UpdateAddKeyWallets < ActiveRecord::Migration[8.0]
  def change
    add_reference :wallets, :user, null: false, foreign_key: true
    add_column :wallets, :key_phrases, :string, array: true, default: []
  end
end
