class Newsletter < ActiveRecord::Base
  has_many :posts
  has_many :subscriptions
  belongs_to :user
end