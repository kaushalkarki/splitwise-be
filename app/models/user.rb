class User < ApplicationRecord
  mount_uploader :image, ImageUploader
  has_secure_password
  has_many :group_subscriptions
  has_many :groups, through: :group_subscriptions

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone, length: { is: 10 }, allow_blank: true
end