class DashboardController < ApplicationController
  before_action :require_login

  PER_PAGE = 10

  def index
    @total_events = Event.search(params).count
    @current_page = [ params[:page].to_i, 1 ].max
    @total_pages = (@total_events.to_f / PER_PAGE).ceil
    offset = (@current_page - 1) * PER_PAGE
    @events = Event.search(params).order(starts_at: :asc).offset(offset).limit(PER_PAGE)
  end
end
