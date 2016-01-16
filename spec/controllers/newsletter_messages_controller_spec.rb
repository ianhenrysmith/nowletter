require "rails_helper"

RSpec.describe NewsletterMessagesController, type: :controller do
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
    context "new newsletter" do
      let(:body) { "hello" }

      context "new user" do
        it "creates a newsletter with slug" do
          expect {
            post :create, params
          }.to change {
            Newsletter.count
          }.by(1)
        end

        it "creates a user" do
          expect {
            post :create, params
          }.to change {
            User.count
          }.by(1)
        end
      end

      context "existing user" do
        before do
          user
        end

        it "creates a newsletter for user" do
          expect {
            post :create, params
          }.to change {
            user.newsletters.count
          }.by(1)
        end

        it "does not create a user" do
          expect {
            post :create, params
          }.to_not change {
            User.count
          }
        end
      end
    end

    context "setting name" do
      let(:body) { "Coffee 'n Beans News" }

      before do
        create(:newsletter, user: user, slug: nil, title: nil)
      end

      it "sets the slug of the user's newsletter" do
        expect {
          post :create, params
        }.to change {
          Newsletter.where(slug: "coffeenbeansnews").count
        }.by(1)
      end

      it "sets the title of the user's newsletter" do
        expect {
          post :create, params
        }.to change {
          Newsletter.where(title: body).count
        }.by(1)
      end
    end

    context "new post" do
      let(:body) { "hello faces and junk" }

      before do
        create(:newsletter, user: user)
      end

      it "creates a post" do
        post :create, params
        
        expect(Post.last.body).to eql("hello faces and junk")
      end
    end

    context "sending a post" do
      let(:body) { "yes!" }

      before do
        newsletter = create(:newsletter, user: user)
        create(:post, newsletter: newsletter)

        allow(PostSender).to receive(:perform_async).and_return(true)
      end

      it "sends a newsletter" do
        post :create, params

        expect(PostSender).to have_received(:perform_async).with(Post.last.id)
      end
    end
  end
end
