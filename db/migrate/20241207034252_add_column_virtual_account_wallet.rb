class AddColumnVirtualAccountWallet < ActiveRecord::Migration[8.0]
  def change
    add_column :wallets, :virtual_account, :string, null: false
    add_column :wallets, :tag_name, :string, null: false

    # must unique
    add_index :wallets, [:virtual_account, :tag_name], unique: true
  end
end
