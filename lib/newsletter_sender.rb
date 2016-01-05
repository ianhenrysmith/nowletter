class NewsletterSender
  include Sidekiq::Worker

  def perform(newsletter_id, post_id)
    newsletter = Newsletter.find(newsletter_id)
    post = Post.find(post_id)

    newsletter.subscriptions.each do |subscription|
      user = subscription.user

      TextSender.deliver(post.body, user.phone_number)

      # TODO: mark post as sent
    end
  end
end