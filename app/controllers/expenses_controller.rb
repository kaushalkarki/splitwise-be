class ExpensesController < ApplicationController
  before_action :set_expense, only: [:destroy, :show, :update]
  
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

  def show
    @expense = Expense.includes(:expense_splits).find(params[:id])
    render json: @expense, include: :expense_splits
  end

  def update
    splits_details = params[:transaction][:expense_split]
    
    if @expense.update(transaction_params)
      @expense.expense_splits.destroy_all
      
      splits_details.each do |splits|
        if splits[:userId].to_i == params[:transaction][:payer]
          @expense.expense_splits.create(user_id: splits[:userId], user_amount: splits[:amount], paid: true, owes: false)
        else
          @expense.expense_splits.create(user_id: splits[:userId], user_amount: splits[:amount], paid: false, owes: true)
        end
      end

      render json: @expense, include: :expense_splits
    else
      render json: { error: "Failed to update expense" }, status: :unprocessable_entity
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
