require 'spec_helper'

module CommonSense
  describe EndPoint do
    before(:each) do
      class FooEndPoint
        include EndPoint
        attribute :attribute1, :attribute2
        resources :foos
        resource :foo
      end
    end

    let(:valid_foo) do
      {
        id: 1,
        attribute1: "attribute1",
        attribute2: "attribute2"
      }
    end

    let(:valid_foo_response) do
      {
        "id" => 1,
        "attribute1" => "attribute1",
        "attribute2" => "attribute2"
      }
    end

    describe "save!" do
      describe "without a session" do
        it "should raise Error::SessionException" do
          expect {
            foo = FooEndPoint.new
            foo.save!
          }.to raise_error(Error::SessionEmptyError)
        end
      end

      describe "without id" do
        it "should call create" do
          foo = FooEndPoint.new
          foo.session = double("CommonSense::Session")
          foo.should_receive(:create!)
          foo.save!
        end
      end

      describe "with id" do
        it "should call update" do
          foo = FooEndPoint.new
          foo.session = double("CommonSense::Session")
          foo.id = 1
          foo.should_receive(:update!)
          foo.save!
        end
      end
    end

    describe "save" do
      it "should not raise error" do
        foo = FooEndPoint.new
        foo.session = double("CommonSense::Session")
        foo.should_receive(:create!).and_return { raise Error }
        foo.save.should be_false
      end
    end

    describe "create!" do
      it "should POST resource to CommonSense" do
        foo_data = valid_foo
        foo_data.delete(:id)
        foo = FooEndPoint.new(foo_data)
        session = double("CommonSense::Session")
        session.should_receive(:post).with("/foos.json", {foo: foo_data}).and_return({"foo" => valid_foo})
        session.stub(:response_headers => {"location" => "http://foo.bar/foos/1"})
        session.stub(:response_code => 201)
        foo.stub(:session).and_return(session);

        foo.create!.should be_true
        foo.id.should eq("1")
      end

      it "should raise exception where recive error (not 201) from commonSense" do
        expect {
          foo = FooEndPoint.new
          session = double("CommonSense::Session")
          session.stub(:post)
          session.stub(response_code: 409)
          session.stub(:errors)
          foo.session = session
          foo.create!
        }.to raise_error(Error::ResponseError)
      end
    end

    describe "create" do
      it "should not raise exception" do
        foo = FooEndPoint.new
        foo.stub(:create!).and_return { raise Error }
        foo.create.should be_false
      end
    end

    describe "retrive!" do
      it "should raise exception with no id" do
        expect {
          foo = FooEndPoint.new
          foo.session = double("CommonSense::Session")
          foo.retrieve!
        }.to raise_error(Error::ResourceIdError)
      end

      it "should GET Resource from CommonSense" do
        foo = FooEndPoint.new(id: 1)
        session = double("CommonSense::Session")
        session.should_receive(:get).with("/foos/1.json").and_return({"foo" => valid_foo})
        session.stub(:response_code => 200)
        foo.session = session

        result = foo.retrieve!
        result.should be_true
        foo.id.should eq(1)
        foo.attribute1.should eq("attribute1")
        foo.attribute2.should eq("attribute2")
      end
    end

    describe "retrieve" do
      it "should not raise error" do
        foo = FooEndPoint.new
        foo.stub(:retrieve!).and_return { raise Error }
        foo.retrieve.should be_false
      end
    end

    describe "update!" do
      it "should PUT Resource to CommonSense" do
        foo_data = valid_foo
        foo = FooEndPoint.new(foo_data)
        session = double("CommonSense::Session")
        session.should_receive(:put).with("/foos/1.json", {foo: foo_data}).and_return({"foo" => valid_foo})
        session.stub(:response_code => 200)
        foo.session = session

        foo.update!.should be_true
      end
    end

    describe "update" do
      it "should not raise error" do
        foo = FooEndPoint.new
        foo.stub(:update!).and_return { raise Error }
        foo.update.should be_false
      end
    end

    describe "delete!" do
      it "should raise exception with no id" do
        expect {
          foo = FooEndPoint.new
          foo.session = double("CommonSense::Session")
          foo.delete!
        }.to raise_error(Error::ResourceIdError)

      end

      it "should DELETE Resource from CommonSense" do
        foo = FooEndPoint.new(id: 1)
        session = double("CommonSense::Session")
        session.should_receive(:delete).with("/foos/1.json")
        session.stub(:response_code => 200)
        foo.session = session

        result = foo.delete!
        result.should be_true
        foo.id.should be_nil
      end
    end

    describe "delete" do
      it "should not raise error" do
        foo = FooEndPoint.new
        foo.session = double("CommonSense::Session")
        foo.stub(:delete!).and_return { raise Error }
        foo.delete.should be_false
      end
    end
  end
end
