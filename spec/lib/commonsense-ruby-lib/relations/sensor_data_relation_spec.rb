require 'spec_helper'

module CommonSense
  describe SensorDataRelation do

    let(:relation) {
      relation = SensorDataRelation.new
      relation.stub("check_session!").and_return(true)
      relation.stub("get_data").and_return(sensors)
      relation
    }

    let(:data) {
      {
        "data" => [
        {
         "id" => "5150e509b4b735f6290238d3",
         "sensor_id" => "1",
         "value" => "{\"x-axis\":0.259,\"y-axis\":-0.15,\"z-axis\":-9.807}",
         "date" => 1364256004.651,
         "month" => 3,
         "week" => 13,
         "year" => 2013
         },
         {
           "id" => "5150e760b4b735fa29027b27",
           "sensor_id" => "1",
           "value" => "{\"x-axis\":0.191,\"y-axis\":0.069,\"z-axis\":-9.875}",
           "date" => 1364256603.675,
           "month" => 3,
           "week" => 13,
           "year" => 2013
           },
           {
             "id" => "5150e9b7b4b735d04e010ed9",
             "sensor_id" => "1",
             "value" => "{\"x-axis\":0.191,\"y-axis\":-0.028,\"z-axis\":-9.766}",
             "date" => 1364257203.315,
             "month" => 3,
             "week" => 13,
             "year" => 2013
           }
         ]
       }
    }

    let(:relation) {
      sensor_id = "1"
      relation = SensorDataRelation.new(sensor_id)
      relation.stub("check_session!").and_return(true)
      relation.stub("get_data!").and_return(data)
      relation
    }

    describe "build" do
      it "should return a sensorData object" do
        sensor_id = 1
        SensorDataRelation.new(sensor_id).build.should be_a_kind_of(SensorData)
      end
    end

    describe "get_data!" do
      it "should fetch the data point from commonSense" do
        sensor_id = 1
        session = double("Session")
        option = { page: 100, per_page: 99, start_date: 1365278885,
          end_date: 1365278886, last: 1, sort: 'ASC', interval: 300 }
        session.should_receive(:get).with("/sensors/#{sensor_id}/data.json", option)

        relation = SensorDataRelation.new(sensor_id, session)
        relation.get_data!(page:100, per_page: 99, start_date: 1365278885,
          end_date: 1365278886, last: true, sort: 'ASC', interval: 300)
      end
    end

    describe "get_data" do
       it "call get_data! and not throw exception" do
        sensor_id = 1
        relation = SensorDataRelation.new(sensor_id)
        relation.stub(:get_data!).and_return { raise Error }

      expect { relation.get_data }.to_not raise_error
       end
    end

    describe "each" do
      it "should get all sensor data based on the criteria and yield" do
        expect { |b| relation.each(&b) }.to yield_successive_args(SensorData, SensorData, SensorData)
      end
    end

    describe "count" do
      it "should return the total number of sensor data match with criteria" do
        relation.count.should eq(3)
      end
    end

    describe "first" do
      it "should return the first record" do
        session = double("Session")
        option = { page: 0, per_page: 1, sort: 'ASC'}
        sensor_id = "1"
        response = {
          "data" => [
            {
             "id" => "5150e509b4b735f6290238d3",
             "sensor_id" => sensor_id,
             "value" => "{\"x-axis\":0.259,\"y-axis\":-0.15,\"z-axis\":-9.807}",
             "date" => 1364256004.651,
             "month" => 3,
             "week" => 13,
             "year" => 2013
            }
          ]
        }
        session.should_receive(:get).with("/sensors/#{sensor_id}/data.json", option).and_return(response)
        relation = SensorDataRelation.new(sensor_id, session)

        first = relation.first
        first.id.should eq("5150e509b4b735f6290238d3")
        first.sensor_id.should eq("1")
        first.value.should eq("{\"x-axis\":0.259,\"y-axis\":-0.15,\"z-axis\":-9.807}")
        first.date.should eq(1364256004.651)
        first.month.should eq(3)
        first.week.should eq(13)
        first.year.should eq(2013)
      end
    end

    describe "last" do
      it "should return the last record" do
        session = double("Session")
        option = { page: 0, per_page: 1, sort: 'DESC'}
        sensor_id = "1"
        response = {
          "data" => [
            {
             "id" => "5150e9b7b4b735d04e010ed9",
             "sensor_id" => sensor_id,
             "value" => "{\"x-axis\":0.191,\"y-axis\":-0.028,\"z-axis\":-9.766}",
             "date" => 1364257203.315,
             "month" => 3,
             "week" => 13,
             "year" => 2013
            }
          ]
        }
        session.should_receive(:get).with("/sensors/#{sensor_id}/data.json", option).and_return(response)
        relation = SensorDataRelation.new(sensor_id, session)

        last = relation.last
        last.id.should eq("5150e9b7b4b735d04e010ed9")
        last.sensor_id.should eq("1")
        last.value.should eq("{\"x-axis\":0.191,\"y-axis\":-0.028,\"z-axis\":-9.766}")
        last.date.should eq(1364257203.315)
        last.month.should eq(3)
        last.week.should eq(13)
        last.year.should eq(2013)
      end
    end

    describe "where" do
      before(:each) do
        sensor_id = 1
        @relation = SensorDataRelation.new(sensor_id)
        @relation.stub("check_session!").and_return(true)
      end

      describe "page" do
        it "should update page" do
          @relation.where(page: 2)
          @relation.page.should eq(2)
        end
      end

      describe "page" do
        it "should update per_page" do
          @relation.where(per_page: 99)
          @relation.per_page.should eq(99)
        end
      end

      describe "start_date" do
        describe "number given" do
          it "should update the start_date" do
            @relation.where(start_date: 1)
            @relation.start_date.to_f.should eq(1.0)
          end
        end
      end

      describe "start_date" do
        describe "number given" do
          it "should update the end_date" do
            @relation.where(end_date: 1)
            @relation.end_date.to_f.should eq(1.0)
          end
        end
      end

      describe "last" do
        describe "with true value" do
          it "should update the last parameter" do
            [true, false].each do |value|
              @relation.where(last: value)
              @relation.parameter(:last).should be_true
            end
          end
        end

        describe "with invalid parameter" do
          it "should assign true" do
            @relation.where(last: 'a')
            @relation.parameter(:last).should be_true
          end
        end
      end

      describe "sort" do
        describe "valid parameter given" do
          it "should update the sort parameter" do
            @relation.where(sort: 'ASC')
            @relation.parameter(:sort).should eq('ASC')

            @relation.where(sort: 'DESC')
            @relation.parameter(:sort).should eq('DESC')
          end
        end

        describe "invalid parameter given" do
          it "should set parameter to nil" do
            expect { @relation.where(sort: 'foo') }.to raise_error(ArgumentError)
          end
        end
      end

      describe "interval" do
        describe "valid parameter given" do
          it "should update the sort parameter" do
            [604800, 86400, 3600, 1800, 600, 300, 60].each do |interval|
              @relation.where(interval: interval)
              @relation.interval.should eq(interval)
            end
          end
        end

        describe "invalid parameter given" do
          it "should set the parameter to nil" do
            expect { @relation.where(interval: 10) }.to raise_error(ArgumentError)
            expect { @relation.where(interval: 'a') }.to raise_error(ArgumentError)
          end
        end
      end

      describe "from" do
        it "should update start_date parameter" do
          @relation.start_date.should be_nil
          @relation.where(from: 1)
          @relation.start_date.to_i.should eq(1)
        end
      end

      describe "to" do
        it "should update end_date parameter" do
          @relation.end_date.should be_nil
          @relation.where(to: 1)
          @relation.end_date.to_i.should eq(1)
        end
      end
    end

    describe "from" do
      it "should update the start_date parameter" do
        result = relation.from(1)
        result.should be_a_kind_of(SensorDataRelation)
        result.start_date.to_i.should eq(1)
      end
    end

    describe "from" do
      it "should update the end_date parameter" do
        result = relation.to(1)
        result.should be_a_kind_of(SensorDataRelation)
        result.end_date.to_i.should eq(1)
      end
    end

    describe "all" do
      it "return array of all matching sensor data" do
        data = relation.to_a
        data.should be_a_kind_of(Array)
        data.size.should eq(3)
        data[0].should be_a_kind_of(SensorData)
      end
    end
  end
end
