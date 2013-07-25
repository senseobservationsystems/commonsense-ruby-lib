require 'digest/md5'

module CS
  module EndPoint
    class User
      include EndPoint

      resources :users
      resource :user

      attribute :email, :username, :name, :surname, :address, :zipcode,
        :country, :mobile, :uuid, :openid, :password

      def initialize(hash={})
        if hash[:password]
          hash[:password] = Digest::MD5.hexdigest(hash[:password])
        end
        super(hash)
      end

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

      def save!
        raise Error::ClientError, "No session found. use Client#new_user instead" unless @session
        super
      end

      # get groups that this users belongs to
      def groups
        group = Group.new
        group.session = session
        group.groups
      end
    end
  end
end
