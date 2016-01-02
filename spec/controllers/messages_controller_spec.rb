require "rails_helper"

RSpec.describe MessagesController, type: :controller do
  let(:params) { { :From => phone_number, :Body => body } }
  let(:phone_number) { "+17202407787" }
  let(:user) { User.create(phone_number: phone_number) }
  let(:creator_user) { User.create(phone_number: "+13033990315") }
  let(:subscription_newsletter) { Newsletter.create(user: creator_user) }

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
          user
        end

        it "creates a newsletter" do
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

      context "existing newsletter" do
        before do
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

      context "with newsletter" do
        before do
          Newsletter.create(user: user)
        end

        it "creates a post" do
          expect {
            post :create, params
          }.to change {
            Post.count
          }.by(1)
        end
      end

      context "no newsletter" do
        it "does not create a post" do
          expect {
            post :create, params
          }.to_not change {
            Post.count
          }
        end
      end
    end

    context "new subscription" do
      context "with newsletter" do
        let(:body) { "SUB #{newsletter.id} plz" }

        let(:newsletter) { subscription_newsletter }

        context "with user" do
          before do
            user
          end

          it "creates a subscription" do
            expect {
              post :create, params
            }.to change {
              user.subscriptions.count
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
        let(:body) { "SUB 7787" }

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
        let(:body) { "UNSUB #{newsletter.id} plz" }
        let(:newsletter) { subscription_newsletter }

        context "with subscription" do
          before do
            Subscription.create(user: user, newsletter: newsletter)
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

    context "asking for help" do
      let(:body) { "HELP IDK" }

      it "does not create a newsletter" do
        expect {
          post :create, params
        }.to_not change {
          Newsletter.count
        }
      end

      it "does not create a subscription" do
        expect {
          post :create, params
        }.to_not change {
          Subscription.count
        }
      end

      # TODO: does not create a user
    end

    context "gibberish" do
      let(:body) { "wejiofwej fijeowfjio fwejiof jwioef #{rand(3)}" }

      it "does not create a newsletter" do
        expect {
          post :create, params
        }.to_not change {
          Newsletter.count
        }
      end

      it "does not create a subscription" do
        expect {
          post :create, params
        }.to_not change {
          Subscription.count
        }
      end

      # TODO: does not create a user
    end
  end
end