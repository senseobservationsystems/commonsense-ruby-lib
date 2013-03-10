require 'pry'

module CommonSense
  module EndPoint
    attr_accessor :session

    def initialize(hash={})
      from_hash(hash)
    end

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

    def self.included(base)
      base.extend(ClassMethod)
    end

    module ClassMethod
      def attribute(*args)
        attr_accessor *args
        @attribute_set ||= Set.new
        @attribute_set.merge(args)
      end

      def attribute_set
        @attribute_set
      end
    end
  end
end
