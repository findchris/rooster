class RoosterTaskGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :task_name, :type => :string
  
  def generate_task
    template "task.rb", "lib/rooster/tasks/#{task_name.underscore}_task.rb"
  end
end
