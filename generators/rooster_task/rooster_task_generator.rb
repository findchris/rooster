class RoosterTaskGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.directory File.join('lib', 'rooster', 'tasks')

      m.template 'task.rb', "lib/rooster/tasks/#{file_name}_task.rb", :assigns => { :class_name => class_name }

      m.readme('README')
    end
  end
end
