class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      render json: {user: @user}, status: :ok
    else
      render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    if @user.present?
      render json: {user: @user}
    else
      render json: {error: "No user found"}
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      render json: { user: @user }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def get_users_group
    user = User.find_by(id: params[:id])
    render json: {groups: user.groups}
  end

  def send_email
    @user = User.first
    UserMailer.welcome_email(@user).deliver_now
  end

  def users_with_name
    user = User.all.select(:id, :name)
    render json: { user: user }, status: :ok
  end

  def dashboard_data
    user_id = params[:id].to_i
    results = []
  
    GroupSubscription.where(user_id: user_id).distinct.pluck(:group_id).each do |group_id|
      query = Expense.where(group_id: group_id)
      t_id = query.pluck(:id)
      user_ids = GroupSubscription.where(group_id: group_id).distinct.pluck(:user_id)
  
      total = user_ids.map do |id|
        net = calculate_net_balance(id, group_id, query, t_id)
        [id, net]
      end
  
      total_copy = Marshal.load(Marshal.dump(total))
      transactions = Group.settle_expenses(total_copy)
  
      formatted_transactions = transactions.select { |transaction| transaction[:from] == user_id || transaction[:to] == user_id }
      .map do |transaction|
        if transaction[:from] == user_id || transaction[:to] == user_id 
          {from: transaction[:from],to: transaction[:to],amount: transaction[:amount]}
        end
      end
  
      results << formatted_transactions
    end
  
    render json: results.flatten(1)
  end
  

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone, :password, :image)
  end

  def calculate_net_balance(id, group_id, query, t_id)
    query.where(payer: id).sum(:amount) -
      ExpenseSplit.where(expense_id: t_id, user_id: id).sum(:user_amount) +
      Settle.where(group_id: group_id, sender: id).sum(:amount) -
      Settle.where(group_id: group_id, receiver: id).sum(:amount)
  end
end
