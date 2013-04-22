require 'spec_helper'
require 'commonsense-ruby-lib/error'

module CommonSense
  module EndPoint
    describe User do
      def valid_user
        {
          id: 1, email: "foo@bar.com", username: "foo@bar.com", name: "foo",
          surname: "bar", address: "foo", zipcode: "12345", country: "NL",
          mobile: "12345", uuid: "12345", openid: "12345"
        }
      end

      describe "current_user" do
        it "should return current logged in user" do
          user = User.new
          session = double("CommonSense::Session")
          session.stub(:get).with("/users/current.json").and_return({"user" => valid_user}) 

          user.stub(:session).and_return(session);

          user.current_user.should_not be_nil
          valid_user.each {|key, value| user.send(key).should eq(value) }
        end
      end


      describe "save" do

        describe "with id specified" do
        end
      end
    end
  end
end
