class PostSender
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    newsletter = post.newsletter

    newsletter.subscriptions.each do |subscription|
      user = subscription.user

      TextSender.new.deliver(post.body, user.phone_number)
    end

    # TODO: mark post as sent
  end
end