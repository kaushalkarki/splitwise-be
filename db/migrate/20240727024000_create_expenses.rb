class CreateExpenses < ActiveRecord::Migration[7.1]
  def change
    create_table :expenses do |t|
      t.string :description, null: false
      t.float :amount, precision: 2
      t.integer :group_id
      t.integer :payer
      t.date :transaction_date
      t.timestamps
    end
  end
end
