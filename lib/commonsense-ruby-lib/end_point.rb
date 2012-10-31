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

    def to_h
      symbol = instance_variables.reject {|x| x == :@session}
      hash = {}
      symbol.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var)}
      hash
    end
  
  end
end
