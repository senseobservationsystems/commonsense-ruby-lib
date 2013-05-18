module CS
  module Serializer
    def from_hash(hash)
      if hash
        hash.each do |k,v|
          self.instance_variable_set("@#{k}", v) if self.respond_to?(k)
        end
      end
    end

    def to_h(include_nil = true)
      symbol = self.class.attribute_set
      hash = {}
      symbol.each {|var| hash[var] = instance_variable_get("@#{var}")}

      return include_nil ? hash : hash.reject { |k,v| v.nil? }
    end

  end
end
