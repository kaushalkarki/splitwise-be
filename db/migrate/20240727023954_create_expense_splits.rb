class CreateExpenseSplits < ActiveRecord::Migration[7.1]
  def change
    create_table :expense_splits do |t|
      t.integer :expense_id
      t.integer :user_id
      t.float :user_amount, precision: 2
      t.boolean :paid, default: false 
      t.boolean :owes
      t.timestamps
    end
  end
end
