class Group < ApplicationRecord
  has_many :group_subscriptions, dependent: :destroy
  has_many :users, through: :group_subscriptions

  def self.settle_expenses(expenses)
    transactions = []
  
    # Separate positive and negative balances
    positive_balances = expenses.select { |expense| expense[1] > 0 }
    negative_balances = expenses.select { |expense| expense[1] < 0 }
  
    pos_index = 0
    neg_index = 0
  
    while pos_index < positive_balances.length && neg_index < negative_balances.length
      pos_id, pos_value = positive_balances[pos_index]
      neg_id, neg_value = negative_balances[neg_index]
  
      transfer_amount = [pos_value, -neg_value].min
  
      # Update the balances
      positive_balances[pos_index][1] -= transfer_amount
      negative_balances[neg_index][1] += transfer_amount
  
      # Log the transaction
      transactions << { from: neg_id, to: pos_id, amount: transfer_amount }
  
      # Update the indices for the next iteration
      pos_index += 1 if positive_balances[pos_index][1] == 0
      neg_index += 1 if negative_balances[neg_index][1] == 0
    end
  
    transactions
  end

end