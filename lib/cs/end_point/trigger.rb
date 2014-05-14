module CS
  module EndPoint
    class Trigger
      include EndPoint

      attribute :name, :expression, :inactivity, :creation_date

      resources "triggers"
      resource "trigger"

      def initialize(hash={})
        from_hash(hash)
      end
    end
  end
end
