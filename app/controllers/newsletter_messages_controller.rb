class NewsletterMessagesController < ApplicationController
  include MessagesController

  SEND_KEYWORDS = %w(yes y yup send ok please okay ya mhmm do deliver ye yess yep uhuh si verdad)

  def create
    text = if newsletter
      if newsletter.slug.blank?
        set_slug
      elsif SEND_KEYWORDS.include?(formatted_message_body)
        send_post
      else
        create_post
      end
    else
      create_newsletter
    end

    respond_with_text(text)
  end

  private

  def newsletter
    @_newsletter ||= Newsletter.find_by(user: user)
  end

  def create_newsletter
    Newsletter.create(user: user)

    "Welcome to Nowletter! What do you want to call your newsletter?"
  end

  def set_slug
    newsletter.title = message_body
    newsletter.slug = formatted_message_body

    if message_body.present? && formatted_message_body.present? && newsletter.save
      "Cool, everyone can subscribe to your newsletter by texting #{newsletter.slug} to #{subscription_phone_number}"
    else
      "Hmm, that title doesn't quite work, please try another one. Need help? Send us an email at #{support_email}"
    end
  end

  def create_post
    post = Post.create(body: message_body, newsletter: newsletter)

    "Ok, your newsletter will say:\n\n\"#{post.body}\"\n\nReady to send it?"
  end

  def send_post
    post = newsletter.posts.last

    PostSender.perform_async(post.id)

    "Great, sending it!"
  end
end
