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
    limit = params[:limit] || 2
    page = params[:page] || 1
    group_id = params[:id]
    data = Expense.includes(:expense_splits).where(group_id: group_id).order(transaction_date: :desc)
    total_expenses = data.count
    data = data.page(page).per(limit)

    render json: {
      expenses: data.as_json(
        include: {
          expense_splits: {
            only: [:user_id, :user_amount, :paid, :owes]
          }
        },
        only: [:id, :description, :amount, :payer, :transaction_date]
      ),
      meta: {
        count: total_expenses,
        page: page,
        per_page: limit
      }
    }
  end

  def balances
    group_id = params[:id]
    group = Group.find_by(id: group_id)
    users = group.users.order(:name)
    total = []
    summary = []
    users.each do |user| 
      net = Expense.where(payer: user.id).sum(:amount) - ExpenseSplit.where(user_id: user.id).sum(:user_amount)
      total.push([user.id, user.name, net] )
    end
    total_copy = Marshal.load(Marshal.dump(total))
    transactions = settle_expenses(total_copy)
    puts "Transactions:"
    transactions.each do |transaction|
      summary.push([transaction[:from], transaction[:to], transaction[:amount]])
    end
    render json: { total: total, summary: summary }
  end

  def settle_expenses(expenses)
    transactions = []
  
    # Separate positive and negative balances
    positive_balances = expenses.select { |expense| expense[2] > 0 }
    negative_balances = expenses.select { |expense| expense[2] < 0 }
  
    pos_index = 0
    neg_index = 0
  
    while pos_index < positive_balances.length && neg_index < negative_balances.length
      pos_id, pos_name, pos_value = positive_balances[pos_index]
      neg_id, neg_name, neg_value = negative_balances[neg_index]
  
      transfer_amount = [pos_value, -neg_value].min
  
      # Update the balances
      positive_balances[pos_index][2] -= transfer_amount
      negative_balances[neg_index][2] += transfer_amount
  
      # Log the transaction
      transactions << { from: neg_name, to: pos_name, amount: transfer_amount }
  
      # Update the indices for the next iteration
      pos_index += 1 if positive_balances[pos_index][2] == 0
      neg_index += 1 if negative_balances[neg_index][2] == 0
    end
  
    transactions
  end
end
