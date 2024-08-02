class ExpensesController < ApplicationController
  before_action :set_expense, only: [:destroy]
  
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

  def destroy
    if @expense.destroy
      render json: {message: "Successfully deleted"}
    else
      render json: {error: "Failed to delete entry"}
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:description, :amount, :group_id, :payer, :transaction_date, :expense_split)
  end
  
  def set_expense
    @expense = Expense.find(params[:id])
  end
  
end
