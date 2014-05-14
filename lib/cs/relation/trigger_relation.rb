module CS
  module Relation
    class TriggerRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :total, Boolean


      private
      def resource_class
        EndPoint::Trigger
      end

      def get_url
        "/triggers.json"
      end
    end
  end
end
