require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class Debloyer
      def self.tasks()
        [:build, :deploy]
      end

      def initialize(server)
        @server = server
      end

      def build()
        build_deb
      end

      def deploy()
        send_deb
        apply_deb
      end

    private
      
      attr_reader :server

      def from_dir()
        server[:debloyer][:from]
      end

      def build_cmd()
        'fpm'
      end

      def build_options()
        server[:debloyer][:fpm]
      end

      def build_deb()
        system(build_cmd, build_options, from_dir)
      end

      def deb_name()
        "gignite_1.0_amd64.deb"
      end

      def send_deb()
        ssh.put("#{ROOT_PATH}/gignite_1.0_amd64.deb", "/home/ubuntu")
      end

      def apply_deb()
        ssh.ssh("sudo dpkg -i /home/ubuntu/#{deb_name}")
      end
    end
  end
end