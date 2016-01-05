class NewsletterSender
  include Sidekiq::Worker

  def perform(newsletter_id, post_id)
    # don't really need newsletter id here
    newsletter = Newsletter.find(newsletter_id)
    post = Post.find(post_id)

    newsletter.subscriptions.each do |subscription|
      user = subscription.user

      TextSender.new.deliver(post.body, user.phone_number)
    end

    # TODO: mark post as sent
  end
end