require 'marionetta/command_runner'

module Marionetta
  module Manipulators
    class Debloyer
      def self.tasks()
        [:deploy]
      end
      
      attr_writer :cmd

      def initialize(server)
        @server = server
      end

      def deploy()
        deb_path = create_deb_path
        build_deb(deb_path)
        send_deb(deb_path)
        apply_deb(deb_path)
      end

    private
      
      attr_reader :server

      def cmd()
        @cmd ||= CommandRunner.new(server)
      end

      def from_dir()
        server[:debloyer][:from]
      end

      def build_cmd()
        server[:debloyer][:fpm][:command]
      end

      def build_options()
        server[:debloyer][:fpm][:flags]
      end

      def build_deb()
        cmd.system(*[build_cmd, build_options, from_dir].flatten)
      end

      def deb_name()
        "gignite_1.0_amd64.deb"
      end

      def send_deb()
        cmd.put("#{ROOT_PATH}/#{deb_name}", "/home/ubuntu")
      end

      def apply_deb()
        cmd.ssh("sudo dpkg -i /home/ubuntu/#{deb_name}")
      end
    end
  end
end