desc 'Display a list of all files which are registered for syncing'
usage 'files'
command :status do
  require_setup
  
  files = remote_files.select{|f| f[:action] != :none }
  puts
  if files.empty?
    puts " No changes are required at this time. You can make changes to your remote or"
    puts " local files and and rerun {{dotfiles status}} to see how changes will be applied"
    puts " on your computer."
  else
    puts " The following changes need to be made to your local files to bring them inline"
    puts " with the remote system. Run {{dotfiles sync}} to carry out these changes."
    puts
    puts " You can login at http://mydotfiles.com to make changes to your files or use"
    puts " the {{dotfiles add path/to/file}} command to upload a new file to your your"
    puts " remote MyDotFiles account."
    puts
    for info in files
      puts "     #{info[:action].to_s.gsub('_', ' ').rjust(15)}:   #{info[:filename]}"
    end
  end
  puts
end

desc 'Sync changes between local and remote machines'
usage 'sync'
command :sync do
  require_setup
  
  DotFiles.config.shas = Hash.new unless DotFiles.config.shas.is_a?(Hash)
  
  files = remote_files
  if files.all?{|f| f[:action] == :none}
    error "No changes required at this time."
  else
    for file in files.select{|f| f[:action] != :none}
      case file[:action]
      when :create_local, :update_local
        puts "{{downloading}} #{file[:filename]}"
        contents = remote_file_contents(file[:filename])
        puts "{{saving}} #{file[:filename]}"
        local_path = File.join(ENV['HOME'], file[:filename])
        File.open(local_path, 'w') { |f| f.write(contents) }
        puts "{{saved}} #{contents.size.to_s} bytes to #{local_path}"
        DotFiles.config.shas[file[:filename]] = Digest::SHA1.hexdigest(contents)
      when :update_remote
        puts "{{uploading}} #{file[:filename]}"
        local_path = File.join(ENV['HOME'], file[:filename])
        contents = File.read(local_path)
        save_remote_file(file[:filename], contents)
        puts "{{uploaded}} #{contents.size.to_s} bytes to #{file[:filename]}"
        DotFiles.config.shas[file[:filename]] = Digest::SHA1.hexdigest(contents)
      else
        puts "nothing to do with #{file[:filename]}"
      end
    end
    
    DotFiles.config.last_sync_at = Time.now.utc
    DotFiles.config.save
    
  end
end

desc 'Add a new (or overwrite an existing) file'
usage 'add path/to/dotfile'
command :add do |path|
  filename = path.gsub(/\A#{ENV['HOME']}\//, '')
  local_path = File.join(ENV['HOME'], filename)
  contents = File.read(local_path)
  save_remote_file(filename, contents)
  DotFiles.config.shas[filename] = Digest::SHA1.hexdigest(contents)
  DotFiles.config.save
  puts "#{filename} added to remote successfully"
end

desc 'Pull a remote file to your local file system'
usage 'pull path/to/dotfile'
command :pull do |path|
  filename = path.gsub(/\A#{ENV['HOME']}\//, '')
  local_path = File.join(ENV['HOME'], filename)
  if contents = remote_file_contents(filename)
    File.open(local_path, 'w') { |f| f.write(contents) }
    DotFiles.config.shas[filename] = Digest::SHA1.hexdigest(contents)
    DotFiles.config.save
    puts "Downloaded #{contents.size} bytes to #{local_path}."
  else
    error "Couldn't download remote file from '#{filename}'. Does it exist?"
  end
end
