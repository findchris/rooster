class <%= class_name %>Task < Rooster::Task
  define_schedule do |s|
    s.every "10s", :tags => self.name do
  
      # Your code here, eg: User.send_due_invoices!
      log "I'm running every 10 seconds! #{Time.now.to_s(:db)}" # delete me, really. :D

      # this is required to keep the tasks from eating all the free connections:
      ActiveRecord::Base.connection_pool.release_connection
    end
  end
end