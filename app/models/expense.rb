class Expense < ApplicationRecord
  belongs_to :user, foreign_key: :payer
  # belongs_to :group
  has_many :expense_splits, dependent: :destroy
end
