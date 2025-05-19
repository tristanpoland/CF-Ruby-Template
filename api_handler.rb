require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'sqlite3'

class TaskAPIHandler < Sinatra::Base
  # Configure JSON API handling
  before do
    content_type :json if request.accept?('application/json')
  end
  
  # Error handling for API
  error 400..599 do
    status response.status
    json({ error: env['sinatra.error'].message })
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
    begin
      data = JSON.parse(request.body.read)
      task = Task.create(
        title: data['title'],
        description: data['description'],
        completed: data['completed'] || false
      )
      
      status 201
      json task
    rescue JSON::ParserError
      status 400
      json({ error: "Invalid JSON" })
    end
  end
  
  # Update a task
  put '/api/tasks/:id' do
    task = Task.find(params[:id])
    
    if task
      begin
        data = JSON.parse(request.body.read)
        task = Task.update(
          params[:id],
          title: data['title'],
          description: data['description'],
          completed: data.key?('completed') ? data['completed'] : nil
        )
        json task
      rescue JSON::ParserError
        status 400
        json({ error: "Invalid JSON" })
      end
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
end