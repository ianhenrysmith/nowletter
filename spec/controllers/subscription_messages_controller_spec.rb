require "rails_helper"

RSpec.describe SubscriptionMessagesController, type: :controller do
  let(:params) { { :From => phone_number, :Body => body } }
  let(:phone_number) { "+17202407787" }
  let(:user) { create(:user, phone_number: phone_number) }
  let(:creator_user) { create(:user, phone_number: "+13033990315") }
  let(:subscription_newsletter) { create(:newsletter, user: creator_user) }
  let(:mock_responder) { double("responder", text: true, headers: {}) }

  before do
    allow(subject).to receive(:generate_response).and_return(mock_responder)
  end

  describe "#create" do
    context "new subscription" do
      context "with newsletter" do
        let(:body) { "#{newsletter.slug}." }

        let(:newsletter) { subscription_newsletter }

        context "with user" do
          before do
            user
          end

          it "creates a subscription for user" do
            expect {
              post :create, params
            }.to change {
              user.subscriptions.count
            }.by(1)
          end

          it "creates a subscription for newsletter" do
            expect {
              post :create, params
            }.to change {
              subscription_newsletter.subscriptions.count
            }.by(1)
          end
        end

        context "no user" do
          it "creates a subscription" do
            expect {
              post :create, params
            }.to change {
              Subscription.count
            }
          end

          it "creates a user" do
            expect {
              post :create, params
            }.to change {
              User.count
            }
          end
        end
      end

      context "no newsletter" do
        let(:body) { "smoolfra" }

        it "does not create a subscription" do
          expect {
            post :create, params
          }.to_not change {
            Subscription.count
          }
        end
      end
    end

    context "unsubscribing" do
      context "with newsletter" do
        let(:body) { "UNSUB #{newsletter.slug}" }
        let(:newsletter) { subscription_newsletter }

        context "with subscription" do
          before do
            create(:subscription, user: user, newsletter: newsletter)
          end

          it "removes the subscription" do
            expect {
              post :create, params
            }.to change {
              Subscription.count
            }.by(-1)
          end
        end

        context "no subscription" do
          it "does nothing" do
            expect {
              post :create, params
            }.to_not change {
              Subscription.count
            }
          end
        end
      end

      context "no newsletter" do
        let(:body) { "UNSUB 1425 plz" }

        it "does nothing" do
          expect {
            post :create, params
          }.to_not change {
            Subscription.count
          }
        end
      end
    end
  end
end
