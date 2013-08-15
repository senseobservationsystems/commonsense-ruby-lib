require 'spec_helper'

module CS
  describe Time do

    context "Initialize with nill" do

      it "should return current time" do
        ::Time.should_receive(:new).with(no_args())

        Time.new
      end

    end

    context "initialize with Time object" do

      it "should set date as time" do
        time = ::Time.new
        Time.new(time).time.should be_instance_of(::Time)
      end

    end

    context "initialize with number" do

      it "should set data based on that time" do
        epoch = 0
        time = Time.new(epoch)
        time.should be_instance_of(Time)
        time.time.to_i.should == 0
      end

    end

    context "initialize with TimeLord" do

      it "should set time property as ruby Time Object" do
        require 'time-lord'
        period = 1.hours.ago
        period.should be_instance_of(TimeLord::Period)
        time = Time.new(period)
        expected = ::Time.new.to_i - 3600
        time.time.to_i.should be_within(1).of(expected)
      end

    end

    context "given an object" do

      it "should get the time by calling to_time on that object" do
        mock = double()
        t = ::Time.new
        mock.should_receive(:to_time).and_return(t)

        time = Time.new(mock)
        time.time.should == t

      end

    end

    it "should proxy object to date" do
      subject = ::Time.new

      subject.should_receive(:to_f).and_return(3.33333)

      time = Time.new(subject).to_f
    end
  end
end
