module Rooster
  module Runner
    
    @@server_options = {:host => "127.0.0.1", :port => "8080"}
    @@error_handler = lambda { |e| Rooster::Runner.log "Exception:  #{e}.  Backtrace:  #{e.backtrace}" }
    @@schedule_all_on_load = true
    mattr_reader :scheduler, :tasks
    mattr_accessor :logger, :server_options, :error_handler, :schedule_all_on_load
  
    def log(message)
      logger.info "Rooster::Runner [#{now}]:  #{message}"
    end
    module_function :log
          
    def schedule_all
      @@tasks.each do |name, task|
        task.schedule
      end
    end
    module_function :schedule_all
        
    def unschedule_all
      @@tasks.each do |name, task|
        task.unschedule
      end
    end
    module_function :unschedule_all
  
    def schedule(name)
      @@tasks[name].schedule
    end
    module_function :schedule
    
    def unschedule(name)
      @@tasks[name].unschedule
    end
    module_function :unschedule

    def run
      log "Loaded #{Rails.env} environment"
      log "Starting #{self.name} at #{now}"
      EventMachine::run do
        @@scheduler = Rufus::Scheduler::EmScheduler.start_new(:thread_name => 'Rooster Scheduler')
        
        load_all
        schedule_all if schedule_all_on_load
 
        EventMachine::start_server @@server_options[:host], @@server_options[:port], Rooster::ControlServer 
        log "Rooster::ControlServer started on #{@@server_options[:host]}:#{@@server_options[:port]}..."

        EventMachine.error_handler { |e| @@error_handler.call(e) }
        def @@scheduler.handle_exception(job, e); @@error_handler.call(e); end  # recurring tasks remain scheduled even on exception
      end
      log "#{self.name} terminated at #{now}"
      logger.flush if logger.respond_to?(:flush)      
    end
    module_function :run


    private
     
      # full filename expected; requires and returns the task class
      def task_from_filename(filename)
        require filename
        File.basename(filename).gsub(".rb", "").camelcase # RAILS_ROOT/rooster/lib/tasks/newsfeed_task.rb => NewsfeedTask
      end
      module_function :task_from_filename

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
        (Time.respond_to?(:zone) && Time.zone) ? Time.zone.now.to_s : Time.now.to_s
      end
      module_function :now
      
      def load_all
        @@tasks = available_tasks.inject({}) do |tasks, task|
          tasks.merge({task => task.constantize.new(@@scheduler)})
        end
      end
      module_function :load_all      
      
      # tasks in scheduled_tasks/*.rb are returned
      def available_tasks
        @@available_tasks ||= returning [] do |tasks|
          Dir[File.join(Rooster::TASKS_DIR, "*.rb")].each do |filename|
            tasks << task_from_filename(filename) || next
          end
        end
      end
      module_function :available_tasks
      
  end
end
