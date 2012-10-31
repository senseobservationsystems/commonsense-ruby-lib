module CommonSense
  class Group
    include CommonSense::EndPoint
    attr_accessor :id, :name, :description, :public
    # get groups that user belongs to
    def current_groups(options={})
      res = session.get("/groups.json", options)
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
