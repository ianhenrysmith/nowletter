class SubscriptionMessagesController < ApplicationController
  include MessagesController

  def create
    text = if message_body.downcase.match(/unsub /)
      unsubscribe
    else
      subscribe
    end

    respond_with_text(text)
  end

  private

  def newsletter(slug=formatted_message_body)
    @_newsletter ||= Newsletter.find_by(slug: slug)
    rescue
    nil
  end

  def subscribe
    if newsletter
      subscription = Subscription.find_by(user: user, newsletter: newsletter)

      if subscription
        "You're already subscribed to this list."
      else
        subscription = Subscription.create(user: user, newsletter: newsletter)

        "Great! You'll now get updates from #{newsletter.title}. You can unsubscribe by texting UNSUB #{newsletter.slug}"
      end
    else
      not_found_text
    end
  end

  def unsubscribe
    slug = formatted_message_body.split("unsub")[1]
    subscription_newsletter = newsletter(slug)

    if subscription_newsletter
      subscription = Subscription.find_by(user: user, newsletter: subscription_newsletter)

      if subscription
        subscription.destroy
        "Unsubscribed from #{subscription_newsletter.title}."
      else
        not_found_text
      end
    else
      not_found_text
    end
  end

  def not_found_text
    "Couldn't find that, did you type it in correctly?"
  end
end
