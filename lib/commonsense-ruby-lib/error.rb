module CommonSense
  class Error < ::RuntimeError
    def exception(message = "")
      RuntimeError.new(message)
    end
  end

  class ResourceIdError < Error
    def exception(message = "No id found for Resrouce: #{self.class}")
      super(message)
    end
  end
  
  class ResponseError < Error
    def exception(message = "Error Response from CommonSense")
      super(message)
    end
  end

  class SessionEmptyError < Error
    def exception(message = "There is no Session found")
      super(message)
    end
  end
end
