class SettlesController < ApplicationController
  before_action :set_settle, only: [:destroy, :update, :show]

  def create
    settle = Settle.create(settle_params)
    if settle.save
      render json: {settle: settle}
    else
      render json: {error: "Failed to save entry"}
    end
  end

  def show
    render json: @settle 
  end

  def update
    if @settle.update(settle_params)
      render json: { settle: @settle }
    else
      render json: { error: "Failed to update entry" }, status: :unprocessable_entity
    end
  end

  def destroy
    if @settle.destroy
      render json: {message: "Successfully deleted"}
    else
      render json: {error: "Failed to delete entry"}
    end
  end
  
  private

  def settle_params
    params.require(:settle).permit(:amount, :group_id, :sender, :receiver, :settle_date)
  end

  def set_settle
    @settle = Settle.find(params[:id])
  end
end
