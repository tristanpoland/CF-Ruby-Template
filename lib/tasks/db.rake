require 'logger'

namespace :db do
  desc "Set up the database"
  task :setup do
    require 'sqlite3'
    
    # Create log directory if it doesn't exist
    FileUtils.mkdir_p('log')
    logger = Logger.new('log/rake.log')
    
    begin
      logger.info "Creating database..."
      db = SQLite3::Database.new('test_app.db')
      db.results_as_hash = true
      
      logger.info "Creating tasks table..."
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          completed BOOLEAN DEFAULT 0,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
      SQL
      
      logger.info "Database setup completed successfully."
      puts "Database setup completed successfully."
    rescue SQLite3::Exception => e
      logger.error "Database setup failed: #{e.message}"
      puts "Database setup failed: #{e.message}"
      exit 1
    end
  end
  
  desc "Seed the database with sample data"
  task :seed do
    require_relative '../app'
    
    puts "Seeding database with sample tasks..."
    
    # Sample task data
    sample_tasks = [
      {
        title: "Learn Ruby",
        description: "Study Ruby programming language basics",
        completed: true
      },
      {
        title: "Build a Sinatra app",
        description: "Create a web application using Sinatra framework",
        completed: true
      },
      {
        title: "Write tests",
        description: "Add RSpec tests for the application",
        completed: false
      },
      {
        title: "Deploy to production",
        description: "Deploy the application to a production server",
        completed: false
      },
      {
        title: "Add documentation",
        description: "Write documentation for the project",
        completed: false
      }
    ]
    
    # Create sample tasks
    sample_tasks.each do |task_data|
      Task.create(task_data)
      puts "Created task: #{task_data[:title]}"
    end
    
    puts "Database seeding completed."
  end
  
  desc "Reset the database (drop and recreate)"
  task :reset => [:drop, :setup, :seed]
  
  desc "Drop the database"
  task :drop do
    if File.exist?('test_app.db')
      File.delete('test_app.db')
      puts "Database dropped."
    else
      puts "Database file doesn't exist. Nothing to drop."
    end
  end
end