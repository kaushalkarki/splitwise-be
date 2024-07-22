class Group < ApplicationRecord
  has_many :group_subscriptions
  has_many :users, through: :group_subscriptions
end
