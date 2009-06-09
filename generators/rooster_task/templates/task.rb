class <%= class_name %>Task < Rooster::Task
  define_schedule do |s|
    s.every "10s", :tags => self.name do      
      log "#{self.name} starting at #{Time.now.to_s(:db)}"
      
      ###
      # Your code here (e.g. User.send_due_invoices!)
      ###
      
      log "#{self.name} completed at #{Time.now.to_s(:db)}"
      ActiveRecord::Base.connection_pool.release_connection
    end
  end
end