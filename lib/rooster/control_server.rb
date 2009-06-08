module Rooster
  module ControlServer  
      
    def receive_data(data)
      if data =~ /^\s*(stop|start|restart)\s+(\S+)\s*$/i
        log_command("#{$1} task #{$2}") do
          case $1.downcase
            when "stop"
              stop_job($2)
            when "start"
              start_job($2)
            when "restart"
              restart_job($2)
          end
        end
      elsif data =~ /^\s*(list)\s*$/i
        log_command($1) do
          log_task_summary
        end
      elsif data =~ /^\s*(exit)\s*$/i
        log_command($1) do
          EventMachine::stop_event_loop
        end        
      elsif data =~ /^\s*(start_all)\s*$/i
        log_command($1) do
          runner.schedule_all
        end
      elsif data =~ /^\s*(stop_all)\s*$/i
        log_command($1) do
          runner.unschedule_all
        end
      else
        log "Unrecognized command:  #{data}"
      end
    end

    def post_init
      log "Connection established.  Commands:"
      log "  list                     Lists running tasks."
      log "  stop_all                 Stops all tasks."
      log "  start_all                Starts all available tasks."
      log "  stop [TaskName]          Stops the specified task."
      log "  start [TaskName]         Starts the specified task."
      log "  exit                     Kills the scheduler."
    end

    def unbind
      log "Connection closed."
    end
  
protected
  
    def stop_job(name)
      job = runner.unschedule(name)
      log(job ? "Successfully stopped: #{name}" : "Failed to stop: #{name}")
      job
    end
  
    def start_job(name)
      job = runner.schedule(name)
      log(job ? "Successfully started: #{name}" : "Failed to start: #{name}")
      job
    end
  
    def restart_job(name)
      stop_job(name)
      start_job(name)
    end
  
    def log(message)
      send_data(message + "\n")
      runner.log(message)
    end
  
    def log_command(description, &block)
      log "Command received: #{description}."
      yield
      log "Command completed: #{description}."
    end
    
    def log_task_summary
      runner.tasks.each do |name, task|
        log " - #{name}:  #{task.status} #{task.schedule_info}"
      end
    end
    
    def runner
      Rooster::Runner
    end
  end
end