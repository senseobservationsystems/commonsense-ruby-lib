require 'digest/md5'

module CommonSense
  class User
    include CommonSense::EndPoint

    attribute :id, :email, :username, :name, :surname, :address, :zipcode,
      :country, :mobile, :uuid, :openid, :password


    def password=(plain_text)
      @password = Digest::MD5.hexdigest(plain_text)
    end

    def password_hashed=(hash)
      self.password = hash
    end

    def current_user
      res = session.get('/users/current.json', )
      return nil unless res && res["user"]

      from_hash(res["user"])
      self
    end

    def reload
      current_user
    end

    def save
      if @id
        self.update
      else
        self.create
      end
    end

    def create
      parameter = { user: self.to_h }
      res = session.post('/users.json', parameter)
      location_header = session.auth_proxy.response_headers["location"]
      user_id = location_header.scan(/.*\/users\/(.*)/)[0] if location_header

      self.id = user_id[0] if user_id
    end

    def update
      binding.pry
      parameter = { user: self.to_h }
      parameter[:user].delete(:password) unless self.password
      res = session.put("/users/#{self.id}.json", parameter)
    end

    # get groups that this users belongs to
    def groups
      group = Group.new
      group.session = session
      group.groups
    end
  end
end
