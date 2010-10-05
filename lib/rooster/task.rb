module Rooster
  class Task
    
   class << self; attr_accessor :tags; end
    
    def initialize(scheduler)
      @scheduler = scheduler
    end
    
    def status
      scheduled? ? "Scheduled" : "Unscheduled"
    end
    
    def scheduled?
      !@job.nil?
    end
    
    def running?
      @job && thread(@job)
    end
    
    def summary
      "#{self.class} [#{status}]>  Schedule info:  #{schedule_info} (#{running_info}) #{tags_info}"
    end
    
    def schedule_info
      scheduled? ? "(#{@job.schedule_info})" : ""
    end
    
    def running_info
      running? ? "Running" : "Not running"
    end
    
    def tags_info
      tags ? "TAGS=[#{tags.join(',')}]" : ""
    end
        
    def tagged_with?(tag)
      tags && tags.include?(tag)
    end
    
    def tags
      self.class.tags
    end
    
    def log(message)
      self.class.log(message)
    end
    
    def kill
      thread(@job).kill if running?
    end
    
    class << self
            
      def define_schedule
        define_method :schedule do
          if scheduled?
            log "#{self.class} already scheduled."
            return
          end
          log "Scheduling #{self.class}..."
          @job = yield @scheduler
          log "#{self.class} successfully scheduled."
        end
        define_method :unschedule do
          unless scheduled?
            log "#{self.class} is not scheduled."
            return
          end
          log "Unscheduling #{self.class}..."
          @job.unschedule
          @job = nil
          log "#{self.class} unscheduled."
        end
      end

      def log(message)
        Rooster::Runner.log(message)
      end
      
    end
    
    private
    
      def thread(job)
        job.respond_to?(:job_thread) ? job.job_thread : job.last_job_thread # different interface for different Rufus::Scheduler versions
      end

  end
end
