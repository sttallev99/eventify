class Api::V1::CommentsController < Api::V1::BaseController
  before_action :set_event

  def index
    events = Event.published.includes(:tickets, :comments, images_attachments: :blob)
    render json: events, each_serializer: EventSerializer
  end

  def show
    event = Event.published.includes(:tickets, :comments, images_attachments: :blob).find(params[:id])
    render json: event, serializer: EventSerializer
  end

  def create
    comment = @event.comments.build(comment_params)
    comment.user = current_user

    if comment.save
      render json: comment, serializer: CommentSerializer
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_event
      @event = Event.find(params[:event_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
