require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'json'
require 'sqlite3'
require_relative 'models/task'

# Configure Sinatra
configure do
  set :port, 4567
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'
  enable :sessions
  set :session_secret, 'your_secret_here'
  
  # Initialize database
  DB = SQLite3::Database.new('test_app.db')
  DB.results_as_hash = true
  
  # Create tasks table if it doesn't exist
  DB.execute <<-SQL
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      completed BOOLEAN DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  SQL
end

# Helper methods
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# Routes
# Home page
get '/' do
  @tasks = Task.all
  erb :index
end

# API endpoints
# Get all tasks
get '/api/tasks' do
  tasks = Task.all
  json tasks
end

# Get a specific task
get '/api/tasks/:id' do
  task = Task.find(params[:id])
  if task
    json task
  else
    status 404
    json({ error: "Task not found" })
  end
end

# Create a new task
post '/api/tasks' do
  data = JSON.parse(request.body.read)
  task = Task.create(
    title: data['title'],
    description: data['description'],
    completed: data['completed'] || false
  )
  
  status 201
  json task
end

# Update a task
put '/api/tasks/:id' do
  task = Task.find(params[:id])
  
  if task
    data = JSON.parse(request.body.read)
    task.update(
      title: data['title'] || task['title'],
      description: data['description'] || task['description'],
      completed: data.key?('completed') ? data['completed'] : task['completed']
    )
    json task
  else
    status 404
    json({ error: "Task not found" })
  end
end

# Delete a task
delete '/api/tasks/:id' do
  task = Task.find(params[:id])
  
  if task
    Task.delete(params[:id])
    status 204
  else
    status 404
    json({ error: "Task not found" })
  end
end

# HTML form routes
# Form to create a new task
get '/tasks/new' do
  erb :new
end

# Form to edit a task
get '/tasks/:id/edit' do
  @task = Task.find(params[:id])
  erb :edit
end

# Create a task from form
post '/tasks' do
  Task.create(
    title: params[:title],
    description: params[:description],
    completed: params[:completed] ? true : false
  )
  redirect '/'
end

# Update a task from form
post '/tasks/:id' do
  task = Task.find(params[:id])
  
  if task
    task.update(
      title: params[:title],
      description: params[:description],
      completed: params[:completed] ? true : false
    )
  end
  
  redirect '/'
end

# Delete a task from form
post '/tasks/:id/delete' do
  Task.delete(params[:id])
  redirect '/'
end

# Start the server if this file is executed directly
if __FILE__ == $0
  puts "Starting server at http://localhost:4567"
  Sinatra::Application.run!
end