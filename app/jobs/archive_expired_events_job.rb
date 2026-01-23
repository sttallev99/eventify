class ArchiveExpiredEventsJob < ApplicationJob
  queue_as :default

  def perform
    events_to_archive = Event.where("ends_at < ? AND status != ?", Time.current, "archived")

    events_to_archive.find_each do |event|
      event.update_column(:status, "archived")
      Rails.logger.info "Archived Event ##{event.id} - #{event.title}"
    end
  end
end
