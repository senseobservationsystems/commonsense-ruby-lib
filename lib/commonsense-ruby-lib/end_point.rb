module CommonSense
  module EndPoint
    attr_accessor :session

    def from_hash(hash)
      hash.each do |k,v|
        self.instance_variable_set("@#{k}", v) if self.respond_to?(k)
      end
    end

    def initialize(hash={})
      from_hash(hash)
    end
  end
end
