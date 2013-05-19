require 'spec_helper'

module CS
  describe Relation do

    let(:relation) {
      class Model
        include Relation
        parameter :number, Integer
        parameter :page, Integer, default: 0
        parameter :per_page, Integer, default: 1000, maximum: 1000
        parameter :start_date, Time
        parameter :end_date, Time
        parameter :date, Time
        parameter :last, Boolean
        parameter :sort, String, valid_values: ["ASC", "DESC"]
        parameter :interval, Integer, valid_values: [604800, 86400, 3600, 1800, 600, 300, 60]
        parameter :sensor_id, String
        parameter_alias :from, :start_date
        parameter_alias :to, :end_date
      end

      Model.new
    }

    describe "parameter" do

      context "Integer parameter with default" do
        it "should assign default parameter" do
          relation.page.should eq(0)
        end

        it "should update the parameter" do
          relation.where(page: 2)
          relation.page.should eq(2)
        end

        it "should set only to a maximum number" do
          relation.where(per_page: 2000)
          relation.per_page.should eq(1000)
        end

        it "should raise exception if not a number given" do
          expect {
            relation.where(number: 'a')
          }.to raise_error(ArgumentError, "Received non Integer value for parameter 'number'")
        end
      end

      context  "Integer with default value" do
        describe "valid parameter given" do
          it "should update the  parameter" do
            [604800, 86400, 3600, 1800, 600, 300, 60].each do |interval|
              relation.where(interval: interval)
              relation.interval.should eq(interval)
            end
          end
        end

        describe "invalid parameter given" do
          it "should set the parameter to nil" do
            expect { relation.where(interval: 10) }.to raise_error(ArgumentError)
            expect { relation.where(interval: 'a') }.to raise_error(ArgumentError)
          end
        end
      end

      context "Time parameter given" do
        describe "number given" do
          it "should update the start_date" do
            relation.where(start_date: 2)
            relation.start_date.to_f.should eq(2.0)
            relation.start_date.should be_kind_of(Time)
          end
        end

        describe "Time given" do
          it "should update the start_date" do
            relation.where(start_date: Time.at(19))
            relation.start_date.to_f.should eq(19)
          end
        end

        describe "Object that respond to 'to_time` given" do
          it "should update the start_date" do
            double = double()
            double.should_receive(:to_time).and_return (Time.at(2))
            relation.where(start_date: double)
            relation.start_date.to_f.should eq(2.0)
            relation.start_date.should be_kind_of(Time)
          end
        end

        describe "Object that not respond to 'to_time' given" do
          it "should raise error" do
            expect { relation.where(end_date: 'foo') }.to raise_error(NoMethodError)
          end
        end
      end

      context "Boolean parameter given" do
        describe "with boolean value" do
          it "should update the last parameter" do
            [true, false].each do |value|
              relation.where(last: value)
              relation.parameter(:last).should be_true
            end
          end
        end

        describe "with value not boolean given, should assign true" do
          it "should assign true" do
            relation.where(last: 'a')
            relation.parameter(:last).should be_true
          end
        end
      end

      context "String parameter with valid value" do
        describe "valid parameter given" do
          it "should update the sort parameter" do
            relation.where(sort: 'ASC')
            relation.parameter(:sort).should eq('ASC')

            relation.where(sort: 'DESC')
            relation.parameter(:sort).should eq('DESC')
          end
        end

        describe "invalid parameter given" do
          it "should set parameter to nil" do
            expect { relation.where(sort: 'foo') }.to raise_error(ArgumentError)
          end
        end
      end
    end

    describe "get_options" do
      it "return parameter that have default value" do
        options = relation.get_options({})
        options[:page].should eq(0)
        options[:per_page].should eq(1000)
      end

      it "should return aliases" do
        option = relation.where(start_date: 1).get_options
        option[:start_date].should eq(1)
      end
    end
  end
end
