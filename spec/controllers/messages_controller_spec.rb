require "rails_helper"

RSpec.describe MessagesController, type: :controller do
  let(:params) { { :From => phone_number, :Body => body } }
  let(:phone_number) { "+17202407787" }

  describe "#create" do
    context "new newsletter" do
      let(:body) { "NEW stuff and things" }

      context "new user" do
        it "creates a newsletter" do
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
          User.create(phone_number: phone_number)
        end

        it "creates a newsletter" do
          expect {
            post :create, params
          }.to change {
            Newsletter.count
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

      context "existing newsletter" do
        before do
          user = User.create(phone_number: phone_number)
          Newsletter.create(user: user)
        end

        it "does not create a newsletter" do
          expect {
            post :create, params
          }.to_not change {
            Newsletter.count
          }
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

    context "new post" do
      let(:body) { "SEND hello faces and junk" }
    end

    # subscribe

    # unsubscribe

    # help

    # gibberish
  end
end
