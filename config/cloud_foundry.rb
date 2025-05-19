require 'sinatra'
require 'sinatra/json'
require 'json'
require_relative 'models/database_connection'

# Cloud Foundry database configuration
configure do
  # Initialize database based on environment
  if ENV['VCAP_SERVICES']
    # Parse VCAP_SERVICES for bound database service
    vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
    
    # Handle various database service types
    if vcap_services.key?('elephantsql')
      # ElephantSQL (PostgreSQL)
      credentials = vcap_services['elephantsql'][0]['credentials']
      DatabaseConnection.setup_postgres(credentials['uri'])
    elsif vcap_services.key?('cleardb')
      # ClearDB (MySQL)
      credentials = vcap_services['cleardb'][0]['credentials']
      DatabaseConnection.setup_mysql(
        credentials['hostname'],
        credentials['username'],
        credentials['password'],
        credentials['name'],
        credentials['port']
      )
    elsif vcap_services.key?('p-mysql')
      # Pivotal MySQL
      credentials = vcap_services['p-mysql'][0]['credentials']
      DatabaseConnection.setup_mysql(
        credentials['hostname'],
        credentials['username'],
        credentials['password'],
        credentials['name'],
        credentials['port']
      )
    else
      # Fallback to SQLite for local development/testing
      DatabaseConnection.setup_sqlite('test_app.db')
    end
  else
    # Local development - use SQLite
    DatabaseConnection.setup_sqlite('test_app.db')
  end
  
  # Create tables if they don't exist
  DatabaseConnection.migrate!
end

# Handle Cloud Foundry port binding
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'

# Cloud Foundry health check endpoint
get '/health' do
  status 200
  json({ status: 'ok', environment: ENV['RACK_ENV'] || 'development' })
end