class Group < ApplicationRecord
  has_many :group_subscriptions, dependent: :destroy
  has_many :users, through: :group_subscriptions
end
