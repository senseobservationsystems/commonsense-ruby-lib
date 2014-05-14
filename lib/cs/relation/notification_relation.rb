module CS
  module Relation
    class NotificationRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :total, Boolean

      private
      def resource_class
        EndPoint::Notification
      end

      def get_url
        "/notifications.json"
      end
    end
  end
end
