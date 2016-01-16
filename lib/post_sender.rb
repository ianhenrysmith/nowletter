class PostSender
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    newsletter = post.newsletter
    send_count = newsletter.send_count

    newsletter.subscriptions.each do |subscription|
      user = subscription.user

      TextSender.new.deliver(post.body, user.phone_number)
      send_count += 1
    end

    post.update_attribute(:sent_at, Time.now)
    newsletter.update_attribute(:send_count, send_count)
  end
end