module Rooster
  class Task
    
    def initialize(scheduler)
      @scheduler = scheduler
    end
    
    def status
      scheduled? ? "Scheduled" : "Unscheduled"
    end
    
    def scheduled?
      !@job.nil?
    end
    
    def summary
      "#{self.class} [#{status}]>  Schedule info:  #{@job.schedule_info}"
    end
    
    def schedule_info
      scheduled? ? "(#{@job.schedule_info})" : ""
    end
    
    def log(message)
      self.class.log(message)
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
  end
end
