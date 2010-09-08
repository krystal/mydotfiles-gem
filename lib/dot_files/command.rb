module DotFiles
  class Command
    
    def initialize(block)
      (class << self;self end).send :define_method, :command, &block
    end
    
    def call(*args)
      arity = method(:command).arity
      args << nil while args.size < arity
      send :command, *args
    end
    
    def error(message, exit_code = 1)
      puts "\e[31m#{message}\e[0m"
      Process.exit(exit_code)
    end
    
    def request(path, options = {})
      uri = URI.parse(DotFiles.site + "/" + path)
      
      if options[:data]
        req = Net::HTTP::Post.new(uri.path)
      else
        req = Net::HTTP::Get.new(uri.path)
      end
      
      
      req.basic_auth(options[:username] || DotFiles.config.username, options[:api_key] || DotFiles.config.api_key)
      
      res = Net::HTTP.new(uri.host, uri.port)
      
      req.add_field("Accept", "application/json")
      req.add_field("Content-type", "application/json")
      
      if options[:data]
        options[:data] = options[:data].to_json
      end
      
      #res.use_ssl = true
      #res.verify_mode = OpenSSL::SSL::VERIFY_NONE
      begin
        Timeout.timeout(10) do
          res = res.request(req, options[:data])
          case res
          when Net::HTTPSuccess
            return res.body.strip
          else
            false
          end
        end
      rescue Timeout::Error
        puts "Sorry, the request timed out. Please try again later."
        Process.exit(1)
      end
    end
    
    def require_setup
      unless DotFiles.config.username && DotFiles.config.api_key
        error "You haven't configured this computer yet. Run 'dotfiles setup' to authorise this computer."
      end
    end
    
    
    ## Return an array of all files which need to be synced
    def remote_files
      if files = get_remote_files
        array = []
        DotFiles.config.shas = Hash.new unless DotFiles.config.shas.is_a?(Hash)
        for filename, remote_sha in files
          hash = {:filename => filename, :action => nil, :local_sha => nil, :local_cached_sha => nil, :remote_sha => remote_sha, :local_path => File.join(ENV['HOME'], filename)}
          
          if File.exist?(hash[:local_path])
            hash[:local_sha] = Digest::SHA1.hexdigest(File.read(hash[:local_path]))
            hash[:local_cached_sha] = DotFiles.config.shas[hash[:filename]]
            
            local_file_changed = (hash[:local_sha] != hash[:local_cached_sha])
            remote_file_changed = (hash[:local_cached_sha] != hash[:remote_sha])
            
            if local_file_changed && remote_file_changed
              hash[:action] = :conflict
            elsif !local_file_changed && remote_file_changed
              hash[:action] = :update_local
            elsif local_file_changed && !remote_file_changed
              hash[:action] = :update_remote
            else
              hash[:action] = :none
            end
          else
            hash[:action] = :create_local
          end
          
          array << hash
        end
        array
      else
        error "We couldn't get a list of files from the remote service. Please try later."
      end
    end
    
    def puts(text = '')
      text = text.to_s
      text.gsub!(/\{\{(.*)\}\}/) { "\e[33m#{$1}\e[0m"}
      super
    end
    
    def remote_file_contents(path)
      req = request("#{DotFiles.config.username}/#{path}")
      req ? JSON.parse(req)['file'] : nil
    end
    
    def save_remote_file(path, contents)
      req = request("save", :data => {:dot_file => {:path => path, :file => contents}})
      req ? true : false
    end
    
    def save_local_file(filename, contents)
      local_path = File.join(ENV['HOME'], filename)
      FileUtils.mkdir_p(File.dirname(local_path))
      File.open(local_path, 'w') { |f| f.write(contents) }
      DotFiles.config.shas[filename] = Digest::SHA1.hexdigest(contents)
      DotFiles.config.save
    end

    private

    def get_remote_files
      req = request("files_list")
      req ? JSON.parse(req) : nil
    end
    
  end
end
