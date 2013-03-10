require 'spec_helper'

module CommonSense

  describe User do
    def valid_user
      {
        id: 1, email: "foo@bar.com", username: "foo@bar.com", name: "foo",
        surename: "bar", address: "foo", zipcode: "12345", country: "NL",
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
      describe "no id specified" do
        it "should POST to /users.json to create user" do
          user_data = valid_user
          user_data[:id] = nil
          user = User.new(user_data)

          session = double("CommonSense::Session")
          session.should_receive(:post).with("/users.json", user_data).and_return({"user" => valid_user}) 
          user.stub(:session).and_return(session);

          user.save

        end
      end

      describe "with id specified" do
        it "should PUT to /users.json to update user" do
          
        end
      end
    end
  end
end
