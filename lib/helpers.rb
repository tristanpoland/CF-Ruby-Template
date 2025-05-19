require 'logger'

# Logger setup
class AppLogger
  def self.logger
    @logger ||= Logger.new('log/app.log')
    @logger.level = Logger::INFO
    @logger
  end
  
  def self.setup(app)
    # Set up logging middleware
    app.use Rack::CommonLogger, logger
    
    # Configure Sinatra's logger
    app.set :logger, logger
    
    # Return the logger
    logger
  end
end

# Request timing middleware
class RequestTimer
  def initialize(app)
    @app = app
  end
  
  def call(env)
    start_time = Time.now
    status, headers, response = @app.call(env)
    end_time = Time.now
    
    # Log request timing
    unless env['PATH_INFO'].include?('/assets/')
      duration = ((end_time - start_time) * 1000).round(2)
      AppLogger.logger.info "Request completed in #{duration}ms: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
    end
    
    [status, headers, response]
  end
end

# Database connection helper
class Database
  def self.connection
    @connection ||= SQLite3::Database.new('test_app.db')
    @connection.results_as_hash = true
    @connection
  end
  
  def self.migrate!
    connection.execute <<-SQL
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        completed BOOLEAN DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    SQL
    AppLogger.logger.info "Database migrations completed."
  end
end

# Flash message helper
class FlashMessage
  def self.set(session, type, message)
    session[:flash] = { type: type, message: message }
  end
end