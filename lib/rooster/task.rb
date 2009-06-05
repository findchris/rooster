module Rooster
  class Task
    class << self

      def scheduler
        Rooster::Runner.scheduler
      end

      def log(message)
        Rooster::Runner.log(message)
      end

    end
  end
end
