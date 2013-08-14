module CS
  module Relation
    class GroupRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :public, Boolean
      parameter :total, Boolean
      parameter :sort, String, valid_values: ["ASC", "DESC"]
      parameter :sort_field, String, valid_values: ["id", "username", "email", "public", "description", "name"]

      def initialize(session=nil)
        @session = session
        page = 0
        per_page = 1000
      end

      # Create a new {EndPoint::Group Group } object.
      #
      # example:
      #
      #    user = client.groups.build
      def build(attribtues={})
        user = EndPoint::Group.new(attribtues)
        user.session = self.session
        user
      end

      def each(&block)
        counter = 0
        self.page || 0;
        begin
          groups = get_data!(get_options({}))

          groups = groups["groups"]
          if !groups.empty?
            groups.each do |group|
              group = EndPoint::Group.new(group)
              group.session = session
              yield group
              counter += 1
              return if @limit && @limit == counter
            end

            self.page += 1
          end

        end while groups.size == self.per_page
      end

      private
      def resource_class
        EndPoint::Group
      end

      def get_url
        "/groups.json"
      end

      def parse_single_resource(groups)
        groups = groups["groups"]
        if !groups.empty?
          group = EndPoint::Group.new(groups[0])
          group.session = self.session

          return group
        end
      end

      def get_single_resource(params={})
        options = {
          page: 0, per_page: 1, public: self.public,
          total: self.total, sort: self.sort, sort_field: self.sort_field
        }
        options.merge!(params)
        get_data(options)
      end
    end
  end
end