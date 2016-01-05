require "rails_helper"

RSpec.describe NewsletterSender do
  subject { described_class.new }
  let(:newsletter) { create(:newsletter, user: creator) }
  let(:creator) { create(:user) }
  let(:subscriber) { create(:user) }
  let(:post) { create(:post, newsletter: newsletter) }
  let!(:subscription) { create(:subscription, user: subscriber, newsletter: newsletter) }

  before do
    allow(TextSender).to receive(:deliver).and_return(true)
  end

  describe "#perform" do
    it "sends the post to subscriber" do
      subject.perform(newsletter.id, post.id)

      expect(TextSender).to have_received(:deliver).with(post.body, subscriber.phone_number)
    end
  end
end