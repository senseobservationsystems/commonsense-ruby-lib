# Wrapper class around time object. Wether it's Time, ActiveSupport::TimeWithZone, or TimeLord
module CS
  class Time
    attr_reader :time

    def initialize(time=nil) 
      if time.nil? 
        @time = ::Time.new unless time
      elsif time.instance_of?(::Time)
        @time = time
      elsif time.kind_of?(::Numeric)
        @time = ::Time.at(time)
      elsif time.class.to_s == "TimeLord::Period"
        @time = ::Time.at(time.beginning)
      else
        @time = time.to_time
      end
    end

    def self.at(epoch)
      ::Time.at(epoch)
    end

    private
    def method_missing(method, *args, &block)
      @time.send(method, *args, &block)
    end
  end
end
