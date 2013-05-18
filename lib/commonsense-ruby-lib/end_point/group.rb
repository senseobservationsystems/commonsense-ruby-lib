module CS
  module EndPoint
    class Group
      include EndPoint

      attr_accessor :id, :name, :description, :public
      # get groups that user belongs to
      def current_groups(options={})
        res = session.get("/groups.json", options)
        return nil unless res

        group_list = res['groups']


        groups =[]
        if group_list
          group_list.each do |group|
            g = Group.new(group)
            g.session = session
            groups << g
          end
        end

        groups
      end
    end
  end
end
