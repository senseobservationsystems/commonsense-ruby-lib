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


      private
      def resource_class
        EndPoint::Group
      end

      def get_url
        "/groups.json"
      end
    end
  end
end
