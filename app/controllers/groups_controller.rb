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

  def create
    name = params[:group][:name]
    emails = params[:group][:members]
    group = Group.create(name: name)
    user_ids = User.where(email: emails).pluck(:id)
    user_ids.each do |id|
      group.group_subscriptions.create(user_id: id)
    end
    
    if group.save
      render json:{group: group}
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
    query = Expense.where(group_id: group_id)
    t_id = query.pluck(:id)
    user_ids = GroupSubscription.where(group_id: group_id).distinct.pluck(:user_id)
    total = []
    summary = []
    user_ids.each do |id|
      net = query.where(payer: id).sum(:amount) - ExpenseSplit.where(expense_id: t_id, user_id: id).sum(:user_amount) + Settle.where(group_id: group_id, sender: id).sum(:amount) - Settle.where(group_id: group_id, receiver:id).sum(:amount)
      total.push([id, net] )
    end
    total_copy = Marshal.load(Marshal.dump(total))
    transactions = Group.settle_expenses(total_copy)
    puts "Transactions:"
    transactions.each do |transaction|
      summary.push([transaction[:from], transaction[:to], transaction[:amount]])
    end
    render json: { total: total, summary: summary }
  end

  def settle_up
    limit = params[:limit] || 2
    page = params[:page] || 1
    group_id = params[:id]
    data = Settle.where(group_id: group_id).order(settle_date: :desc)
    settlement_count = data.count
    data = data.page(page).per(limit)

    render json: {
      settle: data,
      meta: {
        count: settlement_count,
        page: page,
        per_page: limit
      }
    }
  end
end

def dashboard_data
  user_id = params[:user_id] # Expecting an array of group IDs
  results = {}
  group_ids = GroupSubscription.where(user_id: user_id).distinct.pluck(:group_id)
  group_ids.each do |group_id|

    query = Expense.where(group_id: group_id)
    t_id = query.pluck(:id)
    user_ids = GroupSubscription.where(group_id: group_id).distinct.pluck(:user_id)
    total = []
    summary = []
    user_ids.each do |id|
      net = query.where(payer: id).sum(:amount) - ExpenseSplit.where(expense_id: t_id, user_id: id).sum(:user_amount) + Settle.where(group_id: group_id, sender: id).sum(:amount) - Settle.where(group_id: group_id, receiver:id).sum(:amount)
      total.push([id, net] )
    end

    total_copy = Marshal.load(Marshal.dump(total))
    transactions = Group.settle_expenses(total_copy)
    transactions.each do |transaction|
      summary.push([transaction[:from], transaction[:to], transaction[:amount]])
    end

    results[group_id] = { total: total, summary: summary }
  end

  render json: results
end
