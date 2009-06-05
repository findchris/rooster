begin 
  
  require "fileutils"
  include FileUtils::Verbose

  RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..")) unless defined?(RAILS_ROOT)
  source_dir = File.join(File.dirname(__FILE__), "src")
  destination_dir = File.join(RAILS_ROOT, "lib", "rooster")
  template_filename = "rooster_daemon.rb"
  
  FileUtils.mkdir_p(destination_dir)
    
  FileUtils.copy_file(File.join(source_dir, template_filename), destination_dir) unless File.exist?(File.join(destination_dir, template_filename))
  
  puts File.read(File.join(File.dirname(__FILE__), 'README.markdown'))
  
rescue
  puts "Installation encountered an exception:  #{$!}"
end