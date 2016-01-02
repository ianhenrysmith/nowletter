require "rails_helper"

RSpec.describe Message do
  let(:attributes) { { :From => phone_number, :Body => body } }
  let(:phone_number) { "+13036982107" }

  subject { described_class }

  describe ".from_twilio" do
    context "new" do
      let(:body) { "NEW" }

      it "operation is :create" do
        expect(subject.from_twilio(attributes).operation).to eql(:create)
      end
    end

    context "send" do
      let(:body) { "SEND this month is a doozy http://ianhenrysmith.com" }

      it "operation is :send" do
        expect(subject.from_twilio(attributes).operation).to eql(:send)
      end

      it "operand is message body" do
        expect(subject.from_twilio(attributes).operand).to eql("this month is a doozy http://ianhenrysmith.com")
      end
    end

    context "sub" do
      let(:body) { "SUB 7787 " }

      it "operation is :subscribe" do
        expect(subject.from_twilio(attributes).operation).to eql(:subscribe)
      end

      it "shortcode is 7787" do
        expect(subject.from_twilio(attributes).shortcode).to eql("7787")
      end
    end

    context "unsub" do
      let(:body) { "UNSUB 7787" }

      it "operation is :unsubscribe" do
        expect(subject.from_twilio(attributes).operation).to eql(:unsubscribe)
      end

      it "shortcode is 7787" do
        expect(subject.from_twilio(attributes).shortcode).to eql("7787")
      end
    end

    context "help" do
      let(:body) { "HELP me plz" }

      it "operation is :help" do
        expect(subject.from_twilio(attributes).operation).to eql(:help)
      end
    end
  end
end