desc 'Authorise/setup this computer with access to your DotFiles account'
usage 'setup'
command :setup do
  
  require 'highline/import'
  HighLine.track_eof = false
  
  puts "Welcome to MyDotFiles."
  puts
  puts "To begin, we need you to enter your login details so we can authorise"
  puts "this computer to sync dot files from your mydotfiles.com account:"
  puts
  
  username = ask("Username: ")
  password = ask("Password: ") { |q| q.echo = ''}
  
  puts
  puts "Attempting to authenticate you as #{username}..."
  
  url = "https://#{DotFiles.site}/apikey"
  api_key = request("apikey", :username => username, :api_key => password)
  
  if api_key
    DotFiles.config.username = username
    DotFiles.config.api_key = api_key
    DotFiles.config.save
    puts "\e[32mThis computer has now been authorised.\e[0m"
    puts
    puts "We suggest you now run {{dotfiles fetch}} to download all your existing dotfiles. After this point,"
    puts "you will be able to run {{dotfiles sync}} to keep them in sync."
    puts
  else
    error "Your account could not be authorised. Please check your email address & password."
  end

  
end
