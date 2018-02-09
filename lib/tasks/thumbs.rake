require 'erb'
require 'socket'

namespace :mosaico do
  task :make_thumbs, [:template_name] => :environment do |_, args|
    @template = Mosaico.find_template(args.template_name)

    unless @template
      raise "Template #{args.template_name} has not been registered."
    end

    @host = ENV.fetch('APP_HOST', 'localhost')
    @port = ENV.fetch('APP_PORT', 3000).to_i

    begin
      Socket.tcp(@host, @port, connect_timeout: 5) {}
    rescue Errno::ECONNREFUSED
      raise "Couldn't connect to app at #{@host}:#{@port}. Is it running?"
    end

    script_path = File.expand_path('../makeThumbs.js.erb', __FILE__)
    script = ERB.new(File.read(script_path)).result(binding)

    Dir.chdir(Mosaico.vendor_asset_root.join('mosaico')) do
      `npm ls 2>&1`

      if $?.exitstatus != 0
        puts 'Javascript dependencies are not installed, running `npm install`'
        system 'npm install'
      end

      exec("node -e #{Shellwords.escape(script)}")
    end
  end
end
