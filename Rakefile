require 'rake'
require 'rspec/core/rake_task'

desc 'Run tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

desc 'Start the application'
task :start do
  puts "Starting the application..."
  system("ruby app.rb")
end

desc 'Create a sample task'
task :create_sample_task do
  require_relative 'app'
  
  puts "Creating a sample task..."
  task = Task.create(
    title: "Sample Task",
    description: "This is a sample task created using Rake",
    completed: false
  )
  
  puts "Sample task created: #{task[:title]}"
end

desc 'List all tasks'
task :list_tasks do
  require_relative 'app'
  
  puts "Listing all tasks..."
  tasks = Task.all
  
  if tasks.empty?
    puts "No tasks found."
  else
    tasks.each do |task|
      status = task[:completed] ? "[COMPLETED]" : "[PENDING]"
      puts "#{task[:id]}: #{status} #{task[:title]} - #{task[:description]}"
    end
  end
end

desc 'Clear all tasks'
task :clear_tasks do
  require_relative 'app'
  
  puts "Clearing all tasks..."
  DB.execute("DELETE FROM tasks")
  puts "All tasks have been deleted."
end

desc 'Setup development environment'
task :setup do
  system("bundle install")
  puts "Development environment setup complete."
end