module Rooster
  module ControlServer  
    
    def post_init
       log "Connection established.  Send 'exit' to close connection."
     end
  
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
        log_command("list tasks") do
          runner.running_tasks.each do |task|
            log task
          end
        end
      elsif data =~ /^\s*(exit)\s*$/i
        log_command("exit") do
          EventMachine::stop_event_loop
        end
      else
        log "Unrecognized command:  #{data}"
      end
    end
  
    def unbind
      log "Connection closed."
    end
  
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
    
    def runner
      Rooster::Runner
    end
  
  end
end