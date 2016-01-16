concern :MessagesController do
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

  included do
    before_filter :save_params_for_debug
  end

  private

  def subscription_phone_number
    ENV["FRIENDLY_SUBSCRIPTION_PHONE_NUMBER"]
  end

  def support_email
    "hello@nowletter.com"
  end

  def respond_with_text(text)
    response.headers["Content-Type"] = "text/xml"
    render text: generate_response(text).text
  end

  def save_params_for_debug
    unless Rails.env.test?
      ParamMessage.create(body: params.to_json.to_s)
    end
  end

  def generate_response(text)
    Twilio::TwiML::Response.new do |twilio_response|
      twilio_response.Message(text)
    end
  end

  def message_attributes
    params.permit(:From, :Body)
  end

  def phone_number
    params.require(:From)
  end

  def message_body
    params.require(:Body)
  end

  def formatted_message_body
    message_body.downcase.gsub(/[^a-z0-9]/, "")
  end

  def find_or_create_user_from_message
    User.find_or_create_by(phone_number: phone_number)
  end

  def user
    @_user ||= find_or_create_user_from_message
  end
end
