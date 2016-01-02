class MessagesController < ApplicationController

  # stages to processing an incoming SMS message:
  # 1. parse message operation
  # 2. find or create user (in most cases)
  # 3. act on message operation
  # 4. respond to message with action taken
  #
  # an incoming SMS from twilio looks like this:
  # {
  #   "ToCountry"=>"US",
  #   "ToState"=>"",
  #   "SmsMessageSid"=>"SMa2abfd22d2be9200f0f06197dda3e1b3",
  #   "NumMedia"=>"0",
  #   "ToCity"=>"",
  #   "FromZip"=>"80204",
  #   "SmsSid"=>"SMa2abfd22d2be9200f0f06197dda3e1b3",
  #   "FromState"=>"CO",
  #   "SmsStatus"=>"received",
  #   "FromCity"=>"DENVER",
  #   "Body"=>"test 16",
  #   "FromCountry"=>"US",
  #   "To"=>"+18553361427",
  #   "ToZip"=>"",
  #   "NumSegments"=>"1",
  #   "MessageSid"=>"SMa2abfd22d2be9200f0f06197dda3e1b3",
  #   "AccountSid"=>"AC079fe4205ca69a6f4a8f1d601d515760",
  #   "From"=>"+17202407787",
  #   "ApiVersion"=>"2010-04-01",
  #   "controller"=>"messages",
  #   "action"=>"create"
  # }

  def create
    # 1. parse
    @message = Message.from_twilio(message_attributes)

    # 2. find or create user
    @user = find_or_create_user_from_message

    # 3. act on message
    @action_taken = handle_message

    # 4. respond to message
    # response = MessageResponder.respond(@action_taken, @message)
    # MessageSender.send(to: response.recipient, body: response.body)

    # this endpoint just talks to twilio, who don't listen back, so whatevs
    render json: { action_taken: @action_taken }, status: :ok
  end

  private

  def save_params_for_debug
    # ParamMessage.create(body: params.to_json.to_s)
  end

  def message_attributes
    params.permit(:From, :Body)
  end

  def find_or_create_user_from_message
    @_user ||= User.find_or_create_by(phone_number: @message.phone_number)
  end

  def newsletter_for_user
    @_newsletter ||= Newsletter.find_by(user: @user)
  end

  def newsletter_for_message
    @_newsletter ||= Newsletter.find_by(shortcode: @message.shortcode)
  end

  def handle_message
    case @message.operation
    when :create
      # NEW 
      # create newsletter by user, send them a sign up link
      create_newsletter
    when :send
      # SEND <text>
      # create a post by user for newsletter
      create_post
    when :subscribe
      # SUB <newsletter short code>
      # create subscription for user to newsletter
      subscribe_to_newsletter
    when :unsubscribe
      # UNSUB <newsletter short code>
      # delete subscription for user to newsletter
      unsubscribe_from_newsletter
    when :help
      # HELP 
      # send back a help text ?
    else # :invalid
      # ?
      # maybe send back a help text
      # should log exception or something
    end

    # other possible future use cases: stats, re-send, add author...
  end

  def create_newsletter
    @newsletter = newsletter_for_user

    if @newsletter
      :already_created_newsletter
    else
      @newsletter = Newsletter.create(user: @user)
      :created_newsletter
    end
  end

  def create_post
    @newsletter = newsletter_for_user

    if @newsletter
      # TODO: handle blank message case
      @post = Post.create(body: @message.body, newsletter: @newsletter)

      # TODO: send post!
      :created_post
    else
      :no_post_created_no_newsletter
    end
  end

  def subsribe_to_newsletter
    @newsletter = newsletter_for_message

    if @newsletter
      @subscription = Subscription.find_by(user: @user, newsletter: @newsletter)

      if @subscription
        # maybe could do something like:
        # { noun: subscription, verb: :create, success: false, reason: :non_duplication }
        :not_subscribed_to_newsletter_already_subscribed
      else
        @subscription = Subscription.create(user: @user, newsletter: @newsletter)
        :subscribed_to_newsletter
      end
    else
      :not_subscribed_no_newsletter
    end
  end

  def unsubscribe_from_newsletter
    @newsletter = newsletter_for_message

    if @newsletter
      @subscription = Subscription.find_by(user: @user, newsletter: @newsletter)

      if @subscription
        @subscription.destroy
        :unsubscribed_from_newsletter
      else
        :not_unsubscribed_to_newsletter_not_subscribed
      end
    else
      :not_unsubscribed_no_newsletter
    end
  end
end
