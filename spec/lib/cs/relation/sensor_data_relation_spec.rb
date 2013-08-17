require 'spec_helper'

module CS
  module Relation
    describe SensorDataRelation do

      let(:relation) do
        relation = SensorDataRelation.new
        relation.stub("check_session!").and_return(true)
        relation.stub("get_data").and_return(sensors)
        relation
      end

      let(:data) do
        {
          "data" => [{
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
          }]
        }
      end

      let(:relation) do
        sensor_id = "1"
        relation = SensorDataRelation.new(sensor_id)
        relation.stub("check_session!").and_return(true)
        relation.stub("get_data!").and_return(data)
        relation
      end

      describe "build" do
        it "should return a sensorData object" do
          sensor_id = 1
          SensorDataRelation.new(sensor_id).build.should be_a_kind_of(EndPoint::SensorData)
        end
      end

      describe "get_data!" do
        it "should fetch the data point from commonSense" do
          sensor_id = 1
          session = double("Session")
          option = { page: 100, per_page: 99, start_date: 1365278885,
            end_date: 1365278886, last: 1, sort: 'ASC', interval: 300, sensor_id: sensor_id}
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
          relation.get_data.should be_nil
        end
      end

      describe "each_batch" do
        it "should yield data to with multiple pages" do
          sensor_id = 1
          session = double("Session")
          relation = SensorDataRelation.new(sensor_id, session)
          relation.should_receive(:get_data!).once.ordered.with({page: 0, per_page: 3, sensor_id: sensor_id})
            .and_return (data)
          relation.should_receive(:get_data!).once.ordered.with({page: 1, per_page: 3, sensor_id: sensor_id})
            .and_return (data)
          relation.should_receive(:get_data!).once.ordered.with({page: 2, per_page: 3, sensor_id: sensor_id})
            .and_return ({ data: [] })

          relation.page = 0
          relation.per_page = 3
          relation.each_batch {}
        end

      end

      describe "each" do
        it "should get all sensor data based on the criteria and yield" do
          expect { |b| relation.each(&b) }.to yield_successive_args(EndPoint::SensorData, EndPoint::SensorData, EndPoint::SensorData)
        end

        context "limit specified" do
          it "should yield sensor at most specified by limit" do
            relation.limit(1).to_a.count.should eq(1)
          end
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
          sensor_id = "1"
          option = { page: 0, per_page: 1, sort: 'ASC', sensor_id: sensor_id}
          response = {
            "data" => [{
              "id" => "5150e509b4b735f6290238d3",
              "sensor_id" => sensor_id,
              "value" => "{\"x-axis\":0.259,\"y-axis\":-0.15,\"z-axis\":-9.807}",
              "date" => 1364256004.651,
              "month" => 3,
              "week" => 13,
              "year" => 2013
            }]
          }

          session.should_receive(:get).with("/sensors/#{sensor_id}/data.json", option).and_return(response)
          relation = SensorDataRelation.new(sensor_id, session)

          first = relation.first
          first.id.should eq("5150e509b4b735f6290238d3")
          first.sensor_id.should eq("1")
          first.value.should eq("{\"x-axis\":0.259,\"y-axis\":-0.15,\"z-axis\":-9.807}")
          first.date.to_f.should eq(1364256004.651)
          first.month.should eq(3)
          first.week.should eq(13)
          first.year.should eq(2013)
        end
      end

      describe "last" do
        it "should return the last record" do
          session = double("Session")
          sensor_id = "1"
          option = { page: 0, per_page: 1, sort: 'DESC', sensor_id: sensor_id}
          response = {
            "data" => [{
              "id" => "5150e9b7b4b735d04e010ed9",
              "sensor_id" => sensor_id,
              "value" => "{\"x-axis\":0.191,\"y-axis\":-0.028,\"z-axis\":-9.766}",
              "date" => 1364257203.315,
              "month" => 3,
              "week" => 13,
              "year" => 2013
            }]
          }
          session.should_receive(:get).with("/sensors/#{sensor_id}/data.json", option).and_return(response)
          relation = SensorDataRelation.new(sensor_id, session)

          last = relation.last
          last.id.should eq("5150e9b7b4b735d04e010ed9")
          last.sensor_id.should eq("1")
          last.value.should eq("{\"x-axis\":0.191,\"y-axis\":-0.028,\"z-axis\":-9.766}")
          last.date.to_f.should eq(1364257203.315)
          last.month.should eq(3)
          last.week.should eq(13)
          last.year.should eq(2013)
        end
      end
    end
  end
end
