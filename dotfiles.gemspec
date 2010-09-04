Gem::Specification.new do |s|
  s.name = 'dotfiles'
  s.version = "1.0.2"
  s.platform = Gem::Platform::RUBY
  s.summary = "CLI client for the mydotfiles.com"
  
  s.files = Dir.glob("{lib,bin}/**/*")
  s.require_path = 'lib'
  s.has_rdoc = false

  s.bindir = "bin"
  s.executables << "dotfiles"

  s.add_dependency('highline', '>= 1.5.0')
  s.add_dependency('json', '>= 1.1.5')

  s.author = "Adam Cooke"
  s.email = "adam@atechmedia.com"
  s.homepage = "http://atechmedia.com"
end