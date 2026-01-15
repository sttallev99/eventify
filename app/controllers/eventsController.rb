class EventsController < ApplicationController
  before_action :require_login
  before_action :set_event, only: [ :edit, :update, :destroy, :show ]

  def show
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      redirect_to root_path, notice: "Event created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.all
  end

  def update
    if @event.update(event_params)
      redirect_to root_path, notice: "Event updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to root_path, notice: "Event deleted"
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title,
      :location,
      :starts_at,
      :ends_at,
      :category_id,
      :description,
      :published,
      :cancelled,
      tickets_attributes: [
        :id,
        :name,
        :price,
        :quantity_total,
        :quantity_sold,
        :_destroy
      ]
    )
  end
end
