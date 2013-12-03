require 'spec_helper'
require 'cs/error'

module CS
  module EndPoint
    describe User do
      def valid_user
        {
          id: 1, email: "foo@bar.com", username: "foo@bar.com", name: "foo",
          surname: "bar", address: "foo", zipcode: "12345", country: "NETHERLANDS",
          mobile: "12345", UUID: "12345", openid: "12345"
        }
      end

      describe "current_user" do
        it "should return current logged in user" do
          user = User.new
          session = double("CS::Session")
          session.stub(:get).with("/users/current.json").and_return({"user" => valid_user}) 

          user.stub(:session).and_return(session);

          user.current_user.should_not be_nil
          valid_user.each {|key, value| user.send(key).should eq(value) }
        end
      end

      describe "save" do
        context "with id not specified and no session" do
          it "should raise error" do
            user = User.new(valid_user)
            user.id = nil

            expect { user.save! }.to raise_error(Error::ClientError, "No session found. use Client#new_user instead")
          end
        end

        context "with id specified" do
        end
      end
    end
  end
end
