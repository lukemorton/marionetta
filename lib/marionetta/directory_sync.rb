require 'marionetta/commandable'

module Marionetta
  class DirectorySync
    include Commandable

    def self.sync(server, from, to, options = {})
      new(server).sync(from, to, options)
    end

    def initialize(server)
      @server = server
    end

    def sync(from, to, options = {})
      create_dir(to)

      if options.has_key?(:exclude)
        excludes = options[:exclude]
      else
        excludes = []
      end

      sync_dir(from, to, excludes)
    end

  private

    def create_dir(dir)
      cmd.ssh("test -d #{dir} || mkdir -p #{dir}")
    end

    def rsync_exclude_files(from, exclude_files)
      exclude_files = exclude_files.clone

      exclude_files.map! {|f| Dir["#{from}/#{f}"]}
      exclude_files.flatten!

      exclude_files.map! {|f| f.sub(from + '/', '')}

      return exclude_files
    end

    def rsync_exclude_flags(exclude_files)
      exclude_files.map! {|f| ['--exclude', f]}
      exclude_files.flatten!

      return exclude_files
    end

    def sync_dir(from, to, exclude_files = [])
      args = [Dir[from+'/*'], to]

      unless exclude_files.empty?
        args.concat(rsync_exclude_flags(rsync_exclude_files(from, exclude_files)))
      end

      unless cmd.put(*args)
        server[:logger].fatal(cmd.last)
        server[:logger].fatal('Could not rsync cache dir')
        exit(1)
      end
    end
  end
end
