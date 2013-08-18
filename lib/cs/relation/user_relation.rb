module CS
  module Relation
    class UserRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :email, Boolean

      def each(&block)
        counter = 0
        self.page || 0;
        begin
          users = get_data!(get_options({}))

          users = users["users"]
          if !users.empty?
            users.each do |user|
              user = EndPoint::User.new(user)
              user.session = session
              yield user
              counter += 1
              return if @limit && @limit == counter
            end

            self.page += 1
          end

        end while users.size == self.per_page
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
