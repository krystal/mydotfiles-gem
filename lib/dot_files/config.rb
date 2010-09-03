module DotFiles
  class Config
    
    attr_reader :path, :configuration
    
    def initialize(path = DotFiles.configuration_path)
      @path = path
      if File.exist?(path)
        file_data = File.read(path)
        @configuration = (file_data.nil? || file_data.length == 0 ? {} : YAML::load(file_data))
      else
        @configuration = Hash.new
      end
    end
    
    def get(key)
      configuration[key.to_sym]
    end
    
    def set(key, value)
      configuration[key.to_sym] = value
      save
      value
    end
    
    def method_missing(method_name, value = nil)
      method_name = method_name.to_s
      if method_name[-1,1] == '='
        set(method_name.gsub(/\=\z/, ''), value)
      else
        get(method_name)
      end
    end
    
    def save
      File.open(path, 'w') { |f| f.write(YAML::dump(@configuration)) }
    end
    
  end
end
