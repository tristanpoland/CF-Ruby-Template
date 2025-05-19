require 'sqlite3'
require 'pg' rescue LoadError
require 'mysql2' rescue LoadError
require 'logger'

class DatabaseConnection
  class << self
    attr_accessor :connection, :db_type, :logger
    
    def setup_sqlite(db_path)
      require 'sqlite3'
      @db_type = :sqlite
      @connection = SQLite3::Database.new(db_path)
      @connection.results_as_hash = true
      setup_logger
      logger.info "Connected to SQLite database: #{db_path}"
    end
    
    def setup_postgres(connection_uri)
      require 'pg'
      @db_type = :postgres
      @connection = PG.connect(connection_uri)
      setup_logger
      logger.info "Connected to PostgreSQL database"
    end
    
    def setup_mysql(host, username, password, database, port)
      require 'mysql2'
      @db_type = :mysql
      @connection = Mysql2::Client.new(
        host: host,
        username: username,
        password: password,
        database: database,
        port: port
      )
      setup_logger
      logger.info "Connected to MySQL database: #{host}:#{port}/#{database}"
    end
    
    def execute(sql, *params)
      logger.debug "Executing SQL: #{sql} with params #{params.inspect}"
      
      case @db_type
      when :sqlite
        @connection.execute(sql, params)
      when :postgres
        @connection.exec_params(sql, params)
      when :mysql
        @connection.query(sql.gsub('?', '%s'), params)
      else
        raise "Unknown database type: #{@db_type}"
      end
    rescue => e
      logger.error "Database error: #{e.message}"
      raise e
    end
    
    def migrate!
      case @db_type
      when :sqlite
        execute <<-SQL
          CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            completed BOOLEAN DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          );
        SQL
      when :postgres
        execute <<-SQL
          CREATE TABLE IF NOT EXISTS tasks (
            id SERIAL PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            completed BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );
        SQL
      when :mysql
        execute <<-SQL
          CREATE TABLE IF NOT EXISTS tasks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            completed BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );
        SQL
      end
      
      logger.info "Database migrations completed for #{@db_type}"
    end
    
    def last_insert_id
      case @db_type
      when :sqlite
        @connection.last_insert_row_id
      when :postgres
        result = @connection.exec("SELECT lastval();")
        result[0]['lastval'].to_i
      when :mysql
        @connection.last_id
      end
    end
    
    private
    
    def setup_logger
      FileUtils.mkdir_p('log') unless File.directory?('log')
      @logger = Logger.new('log/database.log')
      @logger.level = ENV['RACK_ENV'] == 'production' ? Logger::INFO : Logger::DEBUG
    end
  end
end