require 'digest/md5'

module CommonSense
  class User
    include CommonSense::EndPoint

    resources :users
    resource :user

    attribute :email, :username, :name, :surname, :address, :zipcode,
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


    # get groups that this users belongs to
    def groups
      group = Group.new
      group.session = session
      group.groups
    end
  end
end
