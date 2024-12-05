class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.integer :source_wallet_id, null: true  # nil for credit
      t.integer :target_wallet_id, null: true  # nil for debit
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_type, null: false # credit, debit

      t.timestamps
    end

    add_index :transactions, :source_wallet_id
    add_index :transactions, :target_wallet_idru
  end
end
