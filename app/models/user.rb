class User < ActiveRecord::Base
  has_many :newsletters
  has_many :subscriptions
end