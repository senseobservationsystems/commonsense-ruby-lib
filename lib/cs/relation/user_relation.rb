module CS
  module Relation
    class UserRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :email, Boolean

      def initialize(session=nil)
        @session = session
        page = 0
        per_page = 1000
      end

      # Create a new {EndPoint::User User } object.
      #
      # example:
      #
      #    user = client.users.build
      def build(attribtues={})
        user = EndPoint::User.new(attribtues)
        user.session = self.session
        user
      end

      private
      def resource_class
        EndPoint::User
      end

      def get_url
        "/users.json"
      end
    end
  end
end
