class EventSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :title, :location, :starts_at, :ends_at, :description, :images

  has_many :tickets
  has_many :comments
  has_one :category

  def images
    return [] unless object.images.attached?

    object.images.map do |img|
      rails_blob_url(img, host: "http://localhost:3000")
    end
  end

  def description
    object.description&.body&.to_s
  end
end
