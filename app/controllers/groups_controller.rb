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
    data = Expense.where(group_id: group_id).order(transaction_date: :desc)
    render json: {expenses: data}
  end
end
