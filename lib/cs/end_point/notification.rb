module CS
  module EndPoint
    class Notification
      include EndPoint

      attribute :type, :text, :destination

      resources "notifications"
      resource "notification"

      def initialize(hash={})
        from_hash(hash)
      end
    end
  end
end
