require 'spec_helper'

module CS
  module Relation
    describe GroupRelation do

      let(:relation) do
        relation = GroupRelation.new
        relation.stub("check_session!").and_return(true)
        relation.stub("get_data").and_return(groups)
        relation
      end

      let(:groups) do
        {
          "groups" =>  [
          {
            "accepted" => false,
            "id" => "4765",
            "name" => "Group 1",
            "description" => "Group 1",
            "public" => false
          },
            {
            "accepted" => false,
            "id" => "3155",
            "name" => "Testgroep",
            "description" => "",
            "public" => true
          },
            {
            "accepted" => true,
            "id" => "6072",
            "name" => "ahmy test group",
            "description" => "ahmy test group",
            "public" => true
          }
        ]
      }
      end

      let(:relation) do
        relation = GroupRelation.new
        relation.stub("check_session!").and_return(true)
        relation.stub("get_data!").and_return(groups)
        relation
      end

      describe "get_data!" do
        it "should fetch groups from commonSense" do
          session = double('Session')
          option = {page: 100, per_page: 99, public: 1, total:1, sort: "ASC", sort_field: "name"}
          session.should_receive(:get).with("/groups.json", option)

          relation = GroupRelation.new(session)
          relation.get_data!(page: 100, per_page: 99, public:1, total:1, sort:"ASC", sort_field:"name")
        end
      end

      describe "get_data" do
        it "should not throw an exception" do
          relation = GroupRelation.new
          relation.stub(:get_data!).and_return { raise Error }

          expect { relation.get_data }.to_not raise_error
        end
      end

      describe "each" do
        it "should get all users group  and yield each" do
          session = double('Session')
          relation = GroupRelation.new(session)
          relation.stub("get_data!").and_return(groups)

          expect { |b| relation.each(&b) }.to yield_successive_args(EndPoint::Group, EndPoint::Group, EndPoint::Group)
        end

        context "limit specified" do
          it "should yield sensor at most specified by limit" do
            relation.limit(1).to_a.count.should eq(1)
          end
        end
      end

      describe "count" do
        it "should return the total number of record" do
          relation.count.should eq(3)
        end
      end

      describe "first" do
        it "should return the first record" do
          first = relation.first
          first.should be_kind_of(EndPoint::Group)
          first.name.should eq("Group 1")
        end
      end
      
      describe "last" do
        it "should return the last record" do
          relation = GroupRelation.new
          relation.stub("count").and_return(3)
          relation.should_receive("get_data").with(page:2, per_page:1, public:1, total:1, sort:'ASC', sort_field:'email').and_return({"groups" => [{"name" => "Group 1"}], "total" => 3})

          first = relation.where(public: true, total: true, sort:'ASC', sort_field:'email').last
          first.should be_kind_of(EndPoint::Group)
          first.name.should eq("Group 1")
        end
      end
    end
  end
end
