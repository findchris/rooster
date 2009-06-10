class <%= class_name %>Task < Rooster::Task
  define_schedule do |s|    
    s.every "10s", :tags => self.name do  # refer to:  http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
      
        ###
        # Your code here (e.g. User.send_due_invoices!)
        ###
        
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end