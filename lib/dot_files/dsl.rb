module DotFiles
  module DSL
    
    extend self

    def command(command, options = {}, &block)
      @commands = Hash.new if @commands.nil?
      @commands[command] = Hash.new
      @commands[command][:description] = @next_description
      @commands[command][:usage] = @next_usage
      @commands[command][:flags] = @next_flags
      @commands[command][:required_args] = (options[:required_args] || 0)
      @commands[command][:block] = Command.new(block)
      @next_usage, @next_description, @next_flags = nil, nil, nil
    end
    
    def commands
      @commands || Hash.new
    end
    
    def desc(value)
      @next_description = value
    end
    
    def usage(value)
      @next_usage = value
    end
    
    def flag(key, value)
      @next_flags = Hash.new if @next_flags.nil?
      @next_flags[key] = value
    end 

  end
end