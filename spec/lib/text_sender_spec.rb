require "rails_helper"

RSpec.describe TextSender do
  subject { described_class.new }
  let(:mock_message) { double("message", create: true) }
  let(:body) { "news n stuff" }
  let(:phone_number) { "+13037220968" }

  before do
    allow(subject).to receive(:message).and_return(mock_message)
  end

  describe "#deliver" do
    it "sends body to phone number" do
      subject.deliver(body, phone_number)

      expect(mock_message).to have_received(:create).with({
        from: ENV["PUBLISH_PHONE_NUMBER"],
        to: phone_number,
        body: body
      })
    end
  end
end