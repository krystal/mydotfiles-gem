module DotFiles
  module Dispatch
    class << self
    
      def run(command, args = [])
        command = 'help' if command.nil?
        command = command.to_sym
        if DotFiles::DSL.commands[command]
          if args.size < DotFiles::DSL.commands[command][:required_args]
            puts "usage: #{DotFiles::DSL.commands[command][:usage]}"
          else
            DotFiles::DSL.commands[command][:block].call(*args)
          end
        else
          puts "Command not found. Check 'deploy help' for full information."
        end
      rescue DotFiles::Errors::AccessDenied
        puts "Access Denied. The username & API key stored for your account was invalid. Have you run 'dotfiles setup' on this computer?"
        Process.exit(1)
      rescue DotFiles::Error
        puts "An error occured with your request."
        Process.exit(1)
      end
      
      def load_commands
        Dir[File.join(File.dirname(__FILE__), 'commands', '*.rb')].each do |path|
          DotFiles::DSL.module_eval File.read(path), path
        end
      end
            
    end
  end
end
