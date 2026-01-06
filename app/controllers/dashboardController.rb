class DashboardController < ApplicationController
  before_action :require_login
  def index
    @events = Event.order(starts_at: :asc).limit(10)
  end
end
