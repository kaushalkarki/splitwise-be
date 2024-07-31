class GroupsController < ApplicationController
  def index

  end

  def show
    group = Group.find(params[:id])
    if group.present?
      render json: {group: group}
    else
      render json: {error: "No group found"}
    end
  end

  def get_group_users
    group_id = params[:id]
    group = Group.find_by(id: group_id)
    render json:{users: group.users.order(:name)}
  end

  def expenses
    group_id = params[:id]
    data = Expense.includes(:expense_splits).where(group_id: group_id).order(transaction_date: :desc)
    render json: {
      expenses: data.as_json(
        include: {
          expense_splits: {
            only: [:user_id, :user_amount, :paid, :owes]
          }
        },
        only: [:id, :description, :amount, :payer, :transaction_date]
      )
    }
  end

  def balances
    group_id = params[:id]
    group = Group.find_by(id: group_id)
    users = group.users.order(:name)
    total = []
    users.each do |user| 
      net = Expense.where(payer: user.id).sum(:amount) - ExpenseSplit.where(user_id: user.id).sum(:user_amount)
      total.push([user.id, user.name, net] )
    end
    render json: {total: total}
  end
end
