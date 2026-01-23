class EventsController < ApplicationController
  before_action :require_login
  before_action :set_event, only: [ :edit, :update, :destroy, :show ]

  def show
  end

  def new
    @event = Event.new
  end

  def create
    # build event without images
    @event = current_user.events.build(event_params.except(:images))

    # save the event first
    if @event.save
      # attach images after save
      @event.images.attach(event_params[:images]) if event_params[:images].present?

      redirect_to @event, notice: "Event created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.all
  end

  def update
    # remove images marked for deletion
    if params[:event][:remove_image_ids].present?
      params[:event][:remove_image_ids].each do |id|
        attachment = @event.images.find_by(id: id)
        attachment.purge if attachment
      end
    end

    # update other event attributes (excluding images)
    if @event.update(event_params.except(:images))
      # attach new images if any
      if event_params[:images].present?
        @event.images.attach(event_params[:images])
      end

      redirect_to @event, notice: "Event updated"
    else
      Rails.logger.error(@event.errors.full_messages)
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
        :ticket_type,
        :price,
        :description,
        :quantity_total,
        :quantity_sold,
        :sales_start_at,
        :sales_end_at,
        :_destroy
      ],
      images: [],
      remove_image_ids: []
    )
  end
end
