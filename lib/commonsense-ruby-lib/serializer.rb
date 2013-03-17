module CommonSense
  module Serializer
    def from_hash(hash)
      if hash
        hash.each do |k,v|
          self.instance_variable_set("@#{k}", v) if self.respond_to?(k)
        end
      end
    end

    def to_h
      symbol = self.class.attribute_set
      hash = {}
      symbol.each {|var| hash[var] = instance_variable_get("@#{var}")}
      hash
    end

    def to_parameters
      hash = self.to_h
      hash.reject { |k,v| v.nil? }
    end
  end
end
