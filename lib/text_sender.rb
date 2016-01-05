class TextSender
  # https://www.twilio.com/blog/2012/02/adding-twilio-sms-messaging-to-your-rails-app.html
  # https://www.twilio.com/blog/2014/10/twilio-on-rails-part-2-rails-4-app-sending-sms-mms.html

  def self.deliver(body, phone_number)
    twilio_sid = "AC079fe4205ca69a6f4a8f1d601d515760"
    twilio_token = "2d6ee0ce52e0e8f2e5489fe3c2c54a1b"
    twilio_phone_number = "+18553361427"

    twilio_client = Twilio::REST::Client.new(twilio_sid, twilio_token)

    # TODO: update resource used
    # [DEPRECATED] SMS Resource is deprecated. Please use Messages (https://www.twilio.com/docs/api/rest/message)

    twilio_client.account.sms.messages.create(
      from: twilio_phone_number,
      to: phone_number,
      body: body
    )
  end
end