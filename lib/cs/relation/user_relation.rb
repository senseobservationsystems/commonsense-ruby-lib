module CS
  module Relation
    class UserRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :email, Boolean

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
