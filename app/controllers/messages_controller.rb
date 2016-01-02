class MessagesController < ApplicationController
  before_filter :save_params_for_debug

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
    @response = respond_to_message

    # this endpoint just talks to twilio, who don't listen back, so whatevs
    render json: { action_taken: @action_taken }, status: :ok
  end

  private

  def save_params_for_debug
    unless Rails.env.test?
      ParamMessage.create(body: params.to_json.to_s)
    end
  end

  def message_attributes
    params.permit(:From, :Body)
  end

  def find_or_create_user_from_message
    @_user ||= User.find_or_create_by(phone_number: @message.phone_number) if @message.valid?
  end

  def newsletter_for_user
    @_newsletter ||= Newsletter.find_by(user: @user)
  end

  def newsletter_for_message
    @_newsletter ||=
      Newsletter.find(@message.shortcode)
    rescue
      nil
  end

  def handle_message
    # other possible future use cases: stats, re-send, login...

    # TODO: service objects for handling this business logic
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
      {}
    else # :invalid
      # ?
      # maybe send back a help text
      # should log exception or something
      {}
    end
  end

  def respond_to_message
    # response = MessageResponder.respond(@action_taken)
    # MessageSender.send(to: response.recipient, body: response.body)
  end

  # actions
  # will eventually be NewsletterCreator, PostCreator, etc.
  def create_newsletter
    @newsletter = newsletter_for_user

    if @newsletter
      { noun: :newsletter, verb: :create, success: false, reason: :already_exists }
    else
      @newsletter = Newsletter.create(user: @user)
      { noun: :newsletter, verb: :create, success: true }
    end
  end

  def create_post
    @newsletter = newsletter_for_user

    if @newsletter
      # TODO: handle blank message case
      @post = Post.create(body: @message.body, newsletter: @newsletter)

      # TODO: send post!
      { noun: :post, verb: :create, success: true }
    else
      { noun: :post, verb: :create, success: false, reason: :no_newsletter }
    end
  end

  def subscribe_to_newsletter
    @newsletter = newsletter_for_message

    if @newsletter
      @subscription = Subscription.find_by(user: @user, newsletter: @newsletter)

      if @subscription
        { noun: :subscription, verb: :create, success: false, reason: :already_exists }
      else
        @subscription = Subscription.create(user: @user, newsletter: @newsletter)

        { noun: :subscription, verb: :create, success: true }
      end
    else
      { noun: :subscription, verb: :create, success: false, reason: :no_newsletter }
    end
  end

  def unsubscribe_from_newsletter
    @newsletter = newsletter_for_message

    if @newsletter
      @subscription = Subscription.find_by(user: @user, newsletter: @newsletter)

      if @subscription
        @subscription.destroy
        { noun: :subscription, verb: :delete, success: true }
      else
        { noun: :subscription, verb: :delete, success: false, reason: :no_subscription }
      end
    else
      { noun: :subscription, verb: :delete, success: false, reason: :no_newsletter }
    end
  end
end
