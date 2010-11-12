begin 
  
  require "fileutils"
  include FileUtils::Verbose

  RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..")) unless defined?(RAILS_ROOT)
  source_dir = File.join(File.dirname(__FILE__), "src")
  rails _root = (Rails::VERSION::MAJOR == 2 ? RAILS_ROOT : Rails.root)
  destination_dir = File.join(rails_root, "lib", "rooster")
    
  template_filename = "rooster_daemon.rb"
  source_file = File.join(source_dir, template_filename)
  destination_file = File.join(destination_dir, template_filename)
  
  FileUtils.mkdir_p(destination_dir)
    
  FileUtils.copy_file(source_file, destination_file, :force => true)
  FileUtils.chmod 0755, destination_file
  
  puts File.read(File.join(File.dirname(__FILE__), 'README.markdown'))
  
rescue
  puts "Installation encountered an exception:  #{$!}"
end
