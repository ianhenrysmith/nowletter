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

    it "increments send count on newsletter" do
      expect {
        subject.perform(post.id)
      }.to change {
        newsletter.reload.send_count
      }.from(0).to(1)
    end

    it "sets sent_at on post" do
      expect {
        subject.perform(post.id)
      }.to change {
        post.reload.sent_at.present?
      }.from(false).to(true)
    end
  end
end