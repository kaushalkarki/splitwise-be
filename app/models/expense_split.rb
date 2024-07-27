class ExpenseSplit < ApplicationRecord
  belongs_to :expense
  validates :expense_id, presence: true
  validates :user_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
