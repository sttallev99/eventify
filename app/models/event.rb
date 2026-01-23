class Event < ApplicationRecord
  belongs_to :category
  belongs_to :user

  has_many :tickets, dependent: :destroy
  accepts_nested_attributes_for :tickets, allow_destroy: true

  has_many :comments, dependent: :destroy
  validates_associated :comments


  has_many_attached :images
  has_rich_text :description

  attr_accessor :published
  attr_accessor :cancelled
  before_save :set_status_from_published
  before_update :set_status_from_cancelled

  validates :title, :location, :starts_at, :status, :category_id, presence: true
  validates :starts_at, comparison: { greater_than: -> { Time.current }, message: "Selected date must be bigger than current date" }, if: :starts_at?
  validates :ends_at, presence: true
  validates :ends_at, comparison: { greater_than_or_equal_to: :starts_at, message: "Selected date must be after or equal to the start date" }, if: -> { starts_at.present? && ends_at.present? }
  validate :must_have_at_least_one_ticket

  private

  def set_status_from_published
    self.status = published == true || published == "1" ? "published" : "draft"
  end

  def set_status_from_cancelled
    self.status = "cancelled" if cancelled == true || cancelled == "1"
  end

  def must_have_at_least_one_ticket
    valid_tickets = tickets.reject(&:marked_for_destruction?)

    if valid_tickets.empty?
      errors.add(:base, "Event must have at least one ticket")
    end
  end

  scope :search, ->(params) {
    scope = all
    scope = scope.where("title ILIKE ?", "%#{params[:query]}%") if params[:query].present?
    scope = scope.where("location ILIKE ?", "%#{params[:location]}%") if params[:location].present?
    scope = scope.where("status ILIKE ?", "%#{params[:status]}%") if params[:status].present?
    scope = scope.where("starts_at >= ?", params[:start_date]) if params[:start_date].present?
    scope = scope.where("ends_at <= ?", params[:end_date]) if params[:end_date].present?
    scope
  }
end
