class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets,  id: :uuid do |t|
      # t.uuid :id, default: 'gen_random_uuid()', primary_key: true
      t.string :entity_type, null: false  # STI: User, Team, Stock
      t.integer :entity_id, null: false
      t.decimal :balance, precision: 10, scale: 2, default: 0.0, null: false
      t.timestamps
    end

    add_index :wallets, [:entity_type, :entity_id], unique: true
  end
end
