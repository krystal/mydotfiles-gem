require 'rubygems'
require 'json'
require 'uri'
require 'net/http'
require 'digest'

require 'dot_files/errors'
require 'dot_files/config'
require 'dot_files/dsl'
require 'dot_files/dispatch'
require 'dot_files/command'

module DotFiles
  VERSION = '1.0'
  
  class << self
    
    ## Return a configuration object for configuring access to the gem
    def config
      @config ||= Config.new
    end
    
    def site
      "http://mydotfiles.com"
    end
    
    def configuration_path
      File.join(ENV['HOME'], '.dotfiles')
    end
    
  end
end
