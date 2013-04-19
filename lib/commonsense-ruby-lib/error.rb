module CommonSense
  module Error
    class Error < ::RuntimeError
      def initialize(message = "")
        super(message)
      end
    end

    class ResourceIdError < Error
      def initialize(message = "No id found for Resrouce: #{self.class}")
        super(message)
      end
    end

    class ResourcesError < Error
      def initialize(message = "'resources' is not set for class: #{self.class}")
        super(message)
      end
    end

    class ResourceError < Error
      def initialize(message = "'resource' is not set for class: #{self.class}")
        super(message)
      end
    end

    class ResponseError < Error
      def initialize(message = "Error Response from CommonSense")
        super(message)
      end
    end

    class SessionEmptyError < Error
      def initialize(message = "There is no Session found")
        super(message)
      end
    end

    class RelationError < Error
      def initialize(message = "Error when setting up relation")
        super(message)
      end
    end

    class NotImplementedError < Error
      def initialize(message = "There is unimplemented method")
        super(message)
      end
    end
  end
end
