module CommonSense
  module Relation
    class SensorDataRelation
      include Relation

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

      include Enumerable

      def initialize(sensor_id, session=nil)
        self.sensor_id = sensor_id
        self.session = session
        page = 0
        per_page = 1000
      end

      def get_url
        "/sensors/#{self.sensor_id}/data.json"
      end

      def build(attributes={})
        data = EndPoint::SensorData.new
        data.sensor_id = self.sensor_id
        data.session = self.session
        data
      end

      def each_batch(params={}, &block)
        check_session!
        options = get_options(params)

        page = self.page || 0;
        begin
          options[:page] = page
          data = get_data(options)

          data = data["data"]
          if !data.empty?
            yield data

            page += 1
          end

        end while data.size == self.per_page
      end

      def each(&block)
        self.each_batch do |data|
          data.each do |data_point|
            sensor_data = EndPoint::SensorData.new(data_point)
            sensor_data.sensor_id = self.sensor_id
            sensor_data.session = session
            yield sensor_data
          end
        end
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
        self.start_date = start_date
        self
      end

      def to(end_date)
        self.end_date = end_date
        self
      end

      private
      def parse_single_resource(data)
        data = data["data"]
        data_point = data[0]

        sensor_data = nil
        if !data.empty?
          sensor_data = EndPoint::SensorData.new(data_point)
          sensor_data.sensor_id = self.sensor_id
          sensor_data.session = session
        end

        sensor_data
      end
    end
  end
end
