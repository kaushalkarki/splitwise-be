class GroupsController < ApplicationController
  def index

  end

  def get_group_users
    group_id = params[:id]
    group = Group.find_by(id: group_id)
    render json:{users: group.users.order(:name)}
  end
end
