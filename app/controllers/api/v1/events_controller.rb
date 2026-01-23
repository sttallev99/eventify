class Api::V1::EventsController < Api::V1::BaseController
  def index
    events = Event.where(status: "published").includes(:tickets, :comments)
    render json: events, each_serializer: EventSerializer, host: request.base_url
  end

  def show
    event = Event.with_attached_images
                 .includes(:tickets, :comments)
                 .find(params[:id])

    render json: event, serializer: EventSerializer, instance_options: { host: request.base_url }
  end
end
