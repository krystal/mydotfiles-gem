module DotFiles

  class Error < StandardError; end

  module Errors
    class AccessDenied < Error; end
  end
  
end