class Expense < ApplicationRecord
  belongs_to :user, foreign_key: :payer
  has_many :expense_splits, dependent: :destroy
end
