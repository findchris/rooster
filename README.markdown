Rooster
================

Rooster is a Rails plugin providing a daemon for running and controlling scheduled tasks from within your application. 

It consists of a scheduler daemon running an EventMachine loop that maintains a rufus-scheduler to keep track of your tasks.  An EventMachine-based TCP server listens for control commands to start and stop your tasks.

The idea is to be able to deploy your Rails app with all of the needed functionality for running tasks in the background.  A few example of such tasks:

* Generating nightly reports. 
* Expiring database records.
* Pulling an RSS feed every hour.

You can accomplish these same tasks using a combination of cron and script/runner or rake tasks, but I never liked that approach.

The Daemons gem combined with the daemon_generator plugin works well, but we didn't like managing an army of daemon processes.  Rooster leverage one daemon for the main EventMachine loop, and dynamically schedules/unschedules tasks via the rufus-scheduler.

This has only been tested on Rails 2.2.

Setup
=====

Install the plugin

    script/plugin install git://github.com/findchris/rooster.git

Install required gems

    gem sources -a http://gems.github.com # if you haven't already...

    sudo gem install daemons rufus-scheduler eventmachine

If you want to be able to use english time descriptions in your scheduled tasks, like:

    scheduler.every '3h', :first_at => Chronic.parse('midnight')

then install Chronic:

    sudo gem install chronic

Usage
=====

generate a new scheduled task:

    script/generate rooster_task MyTaskName

fire up the daemon in console mode to test it out

    ruby lib/rooster/rooster_daemon.rb run

When you're done, get your system admin (or switch hats) to add the daemon to the system start-up, and
capistrano deploy scripts, etc.  Something like:

    ruby /path/to/rails_app/lib/rooster/rooster_daemon.rb start

Control Server
==============

You can send commands to the control server using various rake tasks.  For a list of rake tasks, run:
    
    rake -T rooster

As an alternative, you can connect to the control server like so:

    telnet 127.0.0.1 8080

Valid commands are:

* list (lists a summary of tasks including task names and scheduled status)
* start task_name (starts the task with a class name of "task_name")
* stop task_name (stops the task with a class name of "task_name")
* start_all (starts all of the available tasks)
* stop_all (stops all of the available tasks)
* restart task_name (stop/start)
* kill task_name (kills the specified task if it's currently running and unschedules it)
* stop_tag tag (stops all tasks with the specified tag)
* quit (Closes the connection to the control server)
* exit (kills the EventMachine loop)

Customization
=============

You can configure the EventMachine control server like so (defaults to:  {:host => "127.0.0.1", :port => "8080"}):

    Rooster::Runner.server_options = {:host => "1.2.3.4", :port => "5678"}

When the EventMachine or rufus-scheduler encounter an exception, the module Proc Rooster::Runner.error_handler is called.  By default, the exception is logged, but this can be customized like so:

    Rooster::Runner.error_handler = lambda { |e| HoptoadNotifier.notify(e) }

Rooster has extensive logging, and by default will use the Rails logger if available, falling back on logging to STDOUT.  This can be customized:

    Rooster::Runner.logger = Logger.new(STDOUT) # or Logger.new(File.join(Rails.root, "log", "rooster.log"))

By default, all tasks are loaded when the daemon starts.  The can be customized like so:
    
    Rooster::Runner.schedule_all_on_load = false

Notes
=====

Because of the way that forked processes work with the Rails environment, you should ensure that all of your database connections are released after usage, as in:

		ActiveRecord::Base.connection_pool.release_connection
		
Generated Rooster tasks have this included by default with an ensure block. 

Author
======

Chris Johnson

* [@findchris](http://twitter.com/findchris)
* [My Github repo](http://github.com/findchris)
* [My blog](http://foundchris.com)

Credits
======

This project was started by [Steven Soroka](http://blog.stevensoroka.ca) with his [scheduler_daemon plugin](http://github.com/ssoroka/scheduler_daemon/tree/master).  I needed the ability to start/stop individual tasks, and so added an EventMachine-based TCP server to listen for control commands.  My initial fork of scheduler_daemon became quite different from the original project, and so I decided to just create a new project altogether.  My thanks to Steven for kicking this off in the right direction; the result of a few tweets back and forth.

The dependencies of this plugin are all great projects providing great value to the community:  EventMachine, rufus-scheduler, Daemons, and Chronic.

