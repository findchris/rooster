module Rooster
  module ControlServer  
      
    def receive_data(data)
      if data =~ /^\s*(stop|start|restart|kill|start_tag|stop_tag)\s+(\S+)\s*$/i
        log_command("#{$1} task #{$2}") do
          case $1.downcase
            when "stop"
              stop_task($2)
            when "start"
              start_task($2)
            when "restart"
              restart_task($2)
            when "kill"
              kill_task($2)
            # when "start_tag"
            #   start_tasks_with_tag($2)
            when "stop_tag"
              stop_tasks_with_tag($2)
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
          runner.schedule_all_tasks
        end
      elsif data =~ /^\s*(stop_all)\s*$/i
        log_command($1) do
          runner.unschedule_all_tasks
        end
      elsif data =~  /^\s*(quit)\s*$/i
        log_command($1) do
          close_connection_after_writing
        end
      else
        log "Unrecognized command:  #{data}"
      end
    rescue
      send_data "Exception:  #{$!}"
      Rooster::Runner.handle_error($!)
    end

    def post_init
      log "Connection established.  Commands:"
      log "  list                     Lists running tasks."
      log "  stop_all                 Stops all tasks."
      log "  start_all                Starts all available tasks."
      log "  stop [TaskName]          Stops the specified task."
      log "  start [TaskName]         Starts the specified task."
      log "  restart [TaskName]       Stops then starts the specified task."
      # log "  start_tag [tag]          Starts all tasks with the specified tag."
      log "  stop_tag [tag]           Stops all tasks with the specified tag."
      log "  kill [TaskName]          Kills the specified task if it's currently running and unschedules it."
      log "  quit                     Closes the connection to the control server."
      log "  exit                     Kills the scheduler."
    end

    def unbind
      log "Connection closed."
    end
  
protected
  
    def stop_task(name)
      job = runner.unschedule(name)
      log_and_send(job ? "Successfully stopped: #{name}" : "Failed to stop: #{name}")
      job
    end
  
    def start_task(name)
      job = runner.schedule(name)
      log_and_send(job ? "Successfully started: #{name}" : "Failed to start: #{name}")
      job
    end
  
    def kill_task(name)
      killed_thread = runner.kill(name)
      log_and_send(killed_thread ? "Successfully killed: #{name}" : "Failed to kill: #{name} (probably not running)")
      stop_task(name)
      killed_thread
    end
  
    def restart_task(name)
      stop_task(name)
      start_task(name)
    end
    
    # def start_tasks_with_tag(tag)
    #   runner.schedule_by_tag(tag)
    # end
    
    def stop_tasks_with_tag(tag)
      runner.unschedule_by_tag(tag)
    end
    
    def log_and_send(message)
      send_data(message + "\n")
      runner.log(message)      
    end
  
    def log(message)
      runner.log(message)
    end
  
    def log_command(description, &block)
      log_and_send "Command received: #{description}."
      yield
      log_and_send "Command completed: #{description}."
    end
    
    def log_task_summary
      runner.tasks.each do |name, task|
        log_and_send "#{task.summary}"
      end
    end
    
    def runner
      Rooster::Runner
    end
  end
end