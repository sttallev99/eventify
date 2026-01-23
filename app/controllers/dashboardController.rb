class DashboardController < ApplicationController
  before_action :require_login

  PER_PAGE = 10

  def index
    @total_events = Event.search(params).count
    @current_page = [ params[:page].to_i, 1 ].max
    @total_pages = (@total_events.to_f / PER_PAGE).ceil
    offset = (@current_page - 1) * PER_PAGE
    @events = Event.search(params).order(starts_at: :desc).offset(offset).limit(PER_PAGE)
    @columns = [
      { header: "Event Name", attribute: :title },
      { header: "Start Date", value: ->(event) { event.starts_at.strftime("%b %d, %Y") } },
      { header: "End Date", value: ->(event) { event.ends_at.strftime("%b %d, %Y") } },
      { header: "Location", attribute: :location },
      {
        header: "Status",
        value: ->(event) do
          content_tag(:span, event.status,
            class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold " +
              case event.status
              when "published" then "bg-green-100 text-green-800"
              when "draft" then "bg-blue-100 text-blue-800"
              when "cancelled" then "bg-red-100 text-red-800"
              when "out_of_stock" then "bg-yellow-100 text-yellow-800"
              when "archived" then "bg-gray-100 text-gray-800"
              else "bg-gray-100 text-gray-800"
              end
          )
        end
      },
      {
        header: "Actions",
        value: ->(record) do
          safe_join([
            link_to("View", url_for(record), class: "font-medium text-indigo-600 hover:text-indigo-900"),
            link_to("Edit", edit_event_path(record), class: "ml-2 font-medium text-indigo-600 hover:text-indigo-900"),
            link_to("Delete", record,
              method: :delete,
              data: { controller: "delete-confirm", action: "delete-confirm#delete" },
              class: "ml-2 font-medium text-red-600 hover:text-red-900"
            )
          ], " ")
        end
      }
    ]
  end
end
