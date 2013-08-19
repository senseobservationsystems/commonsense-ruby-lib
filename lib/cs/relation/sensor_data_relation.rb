module CS
  module Relation
    class SensorDataRelation
      include Relation
      include Enumerable

      parameter :page, Integer, default: 0
      parameter :per_page, Integer, default: 1000, maximum: 1000
      parameter :start_date, Time
      parameter :end_date, Time
      parameter :date, Time
      parameter :last, Boolean
      parameter :sort, String, valid_values: ["ASC", "DESC"]
      parameter :interval, Integer, valid_values: [604800, 86400, 3600, 1800, 600, 300, 60]
      parameter :sensor_id, String
      parameter_alias :from, :start_date
      parameter_alias :to, :end_date

      def initialize(sensor_id, session=nil)
        self.sensor_id = sensor_id
        self.session = session
      end

      def get_url
        "/sensors/#{self.sensor_id}/data.json"
      end

      def build(attributes={})
        sensor_data = super(attributes)
        sensor_data.sensor_id = self.sensor_id
        sensor_data
      end

      def count
        retval = 0
        each_batch do |data|
          retval += data.size
        end

        retval
      end

      def first
        data = get_data!(page:0, per_page: 1, sort: "ASC")
        parse_single_resource(data)
      end

      def last
        data = get_data!(page:0, per_page: 1, sort: "DESC")
        parse_single_resource(data)
      end

      def from(start_date)
        param_option = self.class.parameters[:start_date]
        self.start_date = process_param_time(:start_date, start_date, param_option)
        self
      end

      def to(end_date)
        param_option = self.class.parameters[:end_date]
        self.end_date = process_param_time(:end_date, end_date, param_option)
        self
      end

      private
      def resource_class
        EndPoint::SensorData
      end
    end
  end
end
