class EventsController < ApplicationController
  before_action :require_login

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      redirect_to root_path, notice: "Event created"
    else
      render :new
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :starts_at, :ends_at, :location, :published, :category_id)
  end
end
