module Rooster
  module Runner
    
    @@server_options = {:host => "localhost", :port => "8080"}
    @@logger = Logger.new(STDOUT)
    @@error_handler = lambda { |e| log "Exception:  #{e}" }
    mattr_reader :scheduler
    mattr_accessor :logger, :server_options, :error_handler
  
    def log(message)
      logger.info "Rooster::Runner [#{now}]:  #{message}"
    end
    module_function :log
    
    def logger
      @@logger ||= if defined?(Rails.logger)
          Rails.logger
        elsif defined?(RAILS_DEFAULT_LOGGER)
          RAILS_DEFAULT_LOGGER
        else
          Logger.new(STDOUT)
        end
    end
    module_function :logger

    def now
      Time.respond_to?(:zone) ? Time.zone.now.to_s : Time.now.to_s
    end
    module_function :now

    # tasks in scheduled_tasks/*.rb are returned
    def available_tasks
      returning [] do |tasks|
        Dir[File.join(Rooster::TASKS_DIR, "*.rb")].each do |filename|
          tasks << task_from_filename(filename) || next
        end
      end
    end
    module_function :available_tasks
  
    def running_tasks
      returning [] do |jobs|
        @@scheduler.all_jobs.each_value do |job|
          jobs << (job.job_id + ":  " + job.tags.first)
        end
      end
    end
    module_function :running_tasks

    # name can be a task name string (e.g. "NewsfeedTask") or the 
    def schedule(name)
      log "Scheduling task #{name.to_s}..."
      (name.is_a?(String) ? name.constantize : name).schedule
    end
    module_function :schedule
  
    def unschedule(name)
      log "Unscheduling task #{name.to_s}..."
      jobs = @@scheduler.find_by_tag(name)
      
      unless jobs.size == 1
        log "Found (#{jobs.size}) '#{name}' tasks running."
        return nil
      end
      jobs.first.unschedule      
    end
    module_function :unschedule

    def run
      log "Loaded #{Rails.env} environment"
      log "Starting #{self.name} at #{now}"
      EventMachine::run do
        @@scheduler = Rufus::Scheduler::EmScheduler.start_new(:thread_name => 'Daemon Scheduler')
  
        log "Scheduling tasks..."
        available_tasks.each { |task_name| schedule(task_name) }
 
        log "Starting SchedulerControlServer on #{@@server_options[:host]}:#{@@server_options[:port]}..."
        EventMachine::start_server @@server_options[:host], @@server_options[:port], Rooster::ControlServer 
        log "SchedulerControlServer started."

        EventMachine.error_handler { |e| error_handler.call(e) }
        def @@scheduler.handle_exception(job, e); error_handler(e); end  # recurring tasks remain scheduled even on exception
      end
      log "#{self.name} terminated at #{now}"
    end
    module_function :run

    private
     
      # full filename expected; requires and returns the task class
      def task_from_filename(filename)
        require filename
        File.basename(filename).gsub(".rb", "").camelcase.constantize # RAILS_ROOT/rooster/lib/tasks/newsfeed_task.rb => NewsfeedTask
      end
      module_function :task_from_filename

  end
end
