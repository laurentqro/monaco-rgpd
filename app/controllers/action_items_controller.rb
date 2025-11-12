class ActionItemsController < ApplicationController
  before_action :set_action_item

  def update
    if @action_item.update(action_item_params)
      redirect_to dashboard_path, notice: "Action mise à jour."
    else
      redirect_to dashboard_path, alert: "Impossible de mettre à jour l'action."
    end
  end

  private

  def set_action_item
    @action_item = Current.account.action_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  end

  def action_item_params
    params.require(:action_item).permit(:status, :snoozed_until)
  end
end
