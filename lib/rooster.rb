require 'eventmachine'
require 'rufus/scheduler'

require 'rooster/control_server'
require 'rooster/runner'
require 'rooster/task'

module Rooster
  ROOSTER_DIR = File.join(Rails.root, "lib", "rooster")
  TASKS_DIR = File.join(ROOSTER_DIR, "tasks")
end