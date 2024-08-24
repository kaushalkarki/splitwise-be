class CreateSettles < ActiveRecord::Migration[7.1]
  def change
    create_table :settles do |t|
      t.integer :sender, null: false
      t.integer :receiver, null: false
      t.integer :group_id
      t.float :amount, precision: 2, null: false
      t.datetime :settle_date, null: false

      t.timestamps
    end

    add_foreign_key :settles, :users, column: :sender
    add_foreign_key :settles, :users, column: :receiver
  end
end
