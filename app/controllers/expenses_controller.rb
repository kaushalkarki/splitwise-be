class ExpensesController < ApplicationController
  
  def create
    splits_details = params[:transaction][:expense_split]
    transaction = Expense.create(transaction_params)
    splits_details.each do |splits|
      if splits[:userId].to_i == params[:transaction][:payer]
        transaction.expense_splits.create(user_id: splits[:userId], user_amount: splits[:amount], paid: true, owes: false)
      else
        transaction.expense_splits.create(user_id: splits[:userId], user_amount: splits[:amount], paid: false, owes: true)
      end
    end

  end

  private

  def transaction_params
    params.require(:transaction).permit(:description, :amount, :group_id, :payer, :transaction_date, :expense_split)
  end
  
  
end
