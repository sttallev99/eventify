class User < ApplicationRecord
  has_secure_password

  has_many :comments, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :purchases, dependent: :destroy

  has_one_attached :avatar

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  validates :password, presence: true, length: { in: 5..30 }, if: -> { new_record? || !password.nil? }, on: [ :create, :update ]
end
