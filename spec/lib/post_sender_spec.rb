require "rails_helper"

RSpec.describe PostSender do
  subject { described_class.new }
  let(:newsletter) { create(:newsletter, user: creator) }
  let(:creator) { create(:user) }
  let(:subscriber) { create(:user) }
  let(:post) { create(:post, newsletter: newsletter) }
  let!(:subscription) { create(:subscription, user: subscriber, newsletter: newsletter) }
  let(:mock_text_sender) { double("text_sender", deliver: true) }

  before do
    allow(TextSender).to receive(:new).and_return(mock_text_sender)
  end

  describe "#perform" do
    it "sends the post to subscriber" do
      subject.perform(post.id)

      expect(mock_text_sender).to have_received(:deliver).with(post.body, subscriber.phone_number)
    end
  end
end