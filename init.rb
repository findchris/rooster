if Rails::VERSION::MAJOR == 2
  require 'rooster'
elsif Rails::VERSION::MAJOR == 3
  require "rails"
  require "eventmachine"
  require 'rufus/scheduler'

  require 'rooster/control_server'
  require 'rooster/runner'
  require 'rooster/task'

  module Rooster    
    class Railtie < Rails::Railtie
      railtie_name :rooster

      initializer "rooster.init" do |app|
         ROOSTER_DIR = File.join(Rails.root, "lib", "rooster")
         TASKS_DIR = File.join(ROOSTER_DIR, "tasks")
      end
    end
  end
end
