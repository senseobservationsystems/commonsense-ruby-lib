module CommonSense
  class User
    include CommonSense::EndPoint

    attr_accessor :id, :email, :username, :name, :surename, :address, :zipcode, 
      :country, :mobile, :uuid, :openid 

    def current_user
      res = session.get('/users/current.json')
      return nil unless res

      from_hash(res["user"]) 
      self
    end

    # get groups that this users belongs to
    def groups
      group = Group.new
      group.session = session
      group.groups
    end
  end
end
