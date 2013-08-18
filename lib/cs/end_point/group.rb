module CS
  module EndPoint
    class Group
      include EndPoint

      attribute :name, :anonymous, :public, :hidden, :access_password, :description,
        :required_sensors, :default_list_users, :default_add_users, :default_remove_users,
        :default_list_sensors, :default_add_sensors, :required_show_id, :required_show_email,
        :required_show_first_name, :required_show_surname, :required_show_phone_number,
        :required_show_username

      resources "groups"
      resource "group"


      def initialize(hash={})
        from_hash(hash)
      end

      # get groups that user belongs to
      def current_groups(options={})
        relation = Relation::GroupRelation.new(@session)
        relation.to_a
      end
    end
  end
end
