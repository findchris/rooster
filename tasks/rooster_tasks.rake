require File.join(File.dirname(__FILE__), "../lib/rooster.rb")

namespace :rooster do
  
  desc "Starts all available tasks."
  task :start_all do
    Rooster::ControlClient.send_command('start_all')
  end

  desc "Stops all available tasks."
  task :stop_all do
    Rooster::ControlClient.send_command('stop_all')
  end
    
  desc "List a summary of tasks and their scheduled status."
  task :list do
    Rooster::ControlClient.send_command('list')
  end
  
  desc "Quit the Rooster Control Server."
  task :exit do
    Rooster::ControlClient.send_command('exit')
  end
  
  desc "Stops the specified task (USAGE:  rake rooster:stop TASK=MyTaskName)"
  task :stop do
    Rooster::ControlClient.send_command('exit')
  end
  
  desc "Starts the specified task (USAGE:  rake rooster:start TASK=MyTaskName)"
  task :start => :task_name do
    Rooster::ControlClient.send_command('exit')
  end
  
  desc "Retarts the specified task (USAGE:  rake rooster:restart TASK=MyTaskName)"
  task :restart => :task_name do
    Rooster::ControlClient.send_command('exit')
  end
  
  task :task_name do
    unless ENV.include?("TASK")
      raise "USAGE:  rake rooster:[task] TASK=MyTaskName" 
    end
    task_name = ENV['TASK']
  end
end