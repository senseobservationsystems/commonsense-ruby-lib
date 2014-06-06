require 'yaml'

module CS
  module CLI
    class Config
      @@config = {}
      @@loaded = false
      @@file = ""

      def self.load_config(file="#{ENV['HOME']}/.cs.yml")
        @@file = file
        @@config = YAML.load_file(file)
        @@loaded = true
      end

      def self.get(key=nil)
        if !@@loaded
          STDERR.puts("WARNING could not load '#{@@file}'. Is it exists ?")
        end

        if key.nil?
          return @@config
        else
          return @@config[key.to_s]
        end
      end
    end
  end
end
