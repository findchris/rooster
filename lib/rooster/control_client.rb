module Rooster
  
  class ControlClientBackend < EventMachine::Connection 
    def receive_data(data)      
      puts data      
      close_connection_after_writing
      sleep 2
      EventMachine::stop_event_loop
    end
  end
  
  module ControlClient
    def send_command(command)
      EventMachine::run do
        client = EventMachine::connect Rooster::Runner.server_options[:host], Rooster::Runner.server_options[:port], Rooster::ControlClientBackend
        client.send_data(command)
      end
    end
    module_function :send_command
  end

end
