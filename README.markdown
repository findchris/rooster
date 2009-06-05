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

To control the server once running, connect to the control server like so:

    telnet 127.0.0.1 8080

Valid commands are:

* list (lists running tasks)
* stop task_name (stops the task with a class name of "task_name")
* start task_name (starts the task with a class name of "task_name")
* restart task_name (stop/start)
* exit (kills the EventMachine loop)

Customization
=============

You can configure the EventMachine control server like so (defaults to:  {:host => "localhost", :port => "8080"}):
    Rooster::Runner.server_options = {:host => "1.2.3.4", :port => "5678"}

Author
======

Chris Johnson

* [@findchris](http://twitter.com/findchris)
* [My Github repo](http://github.com/findchris)
* [My blog](http://foundchris.com)

Credits
======

This project was started by Steven Soroka (http://blog.stevensoroka.ca) with his scheduler_daemon plugin (git://github.com/ssoroka/scheduler_daemon.git).  I needed the ability to start/stop individual tasks, and so added an EventMachine-based TCP server to listen for control commands.  My initial fork of scheduler_daemon became quite different from the original project, and so I decided to just create a new project altogether.  My thanks to Steven for kicking this off in the right direction; the result of a few tweets back and forth.

The dependencies of this plugin are all great projects providing great value to the community:  EventMachine, rufus-scheduler, Daemons, and Chronic.

