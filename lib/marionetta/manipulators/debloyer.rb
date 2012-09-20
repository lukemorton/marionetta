# `Debloyer` was a way of deploying your application using
# .deb files. However I quickly realised using the .deb format
# was limiting since you can only install them on debian and
# ubuntu. Also it's an inefficient way of copying a folder to
# another system!
# 
# **This class is deprecated please take a look at `Deployer`.**
# 
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

      def can?()
        d = server[:debloyer]
        
        if d.has_key?(:from) and d.has_key?(:to)
          return true
        else
          return false
        end
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

      def to_dir()
        server[:debloyer][:to]
      end

      def timestamp()
        Time.new.strftime('%F_%T')
      end

      def create_deb_path()
        "/tmp/#{server[:debloyer][:name]}_#{timestamp}.deb"
      end

      def build_cmd()
        server[:debloyer][:fpm][:command]
      end

      def build_options(deb_path)
        options = server[:debloyer][:fpm][:flags]

        options << ['-n', server[:debloyer][:name]]
        options << ['-p', deb_path]
        options << ['-C', from_dir]
        options << ['--prefix', to_dir]

        options
      end

      def build_deb(deb_path)
        cmd.system(*[build_cmd, build_options(deb_path), '.'].flatten)
      end

      def send_deb(deb_path)
        cmd.put(deb_path, '/tmp')
      end

      def apply_deb(deb_path)
        cmd.ssh("sudo dpkg -i #{deb_path}")
      end
    end
  end
end