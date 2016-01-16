class Newsletter < ActiveRecord::Base
  has_many :posts
  has_many :subscriptions
  belongs_to :user

  validates_uniqueness_of :slug, unless: "slug.nil?"
  validates_presence_of :title, unless: "title.nil?"
end