namespace :rooster do
  
  desc "Starts all available tasks."
  task :start_all => :environment do
    Rooster::ControlClient.send_command('start_all')
  end

  desc "Stops all available tasks."
  task :stop_all => :environment do
    Rooster::ControlClient.send_command('stop_all')
  end
    
  desc "List a summary of tasks and their scheduled status."
  task :list => :environment do
    Rooster::ControlClient.send_command('list')
  end
  
  desc "Quit the Rooster Control Server."
  task :exit => :environment do
    Rooster::ControlClient.send_command('exit')
  end
  
  desc "Stops the specified task (USAGE:  rake rooster:stop TASK=MyTaskName)"
  task :stop => :environment do
    Rooster::ControlClient.send_command('stop ' + get_task)
  end
  
  desc "Starts the specified task (USAGE:  rake rooster:start TASK=MyTaskName)"
  task :start => :environment do
    Rooster::ControlClient.send_command('start ' + get_task)
  end
  
  desc "Retarts the specified task (USAGE:  rake rooster:restart TASK=MyTaskName)"
  task :restart => :environment do
    Rooster::ControlClient.send_command('restart ' + get_task)
  end
  
  def get_task
    unless ENV.include?("TASK")
      raise "USAGE:  rake rooster:[stop|start|restart] TASK=MyTaskName" 
    end
    ENV['TASK']
  end
end