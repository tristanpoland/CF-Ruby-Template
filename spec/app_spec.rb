ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative '../app'

# Prevent the app from actually opening a connection
set :run, false
set :raise_errors, true
set :logging, false

RSpec.describe 'Task Manager App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  before(:each) do
    # Clear the test database before each test
    DB.execute("DELETE FROM tasks")
  end
  
  describe "API endpoints" do
    describe "GET /api/tasks" do
      it "returns an empty array when no tasks exist" do
        get '/api/tasks'
        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq []
      end
      
      it "returns all tasks when tasks exist" do
        # Create a test task
        task = Task.create(title: "Test Task", description: "Test Description")
        
        get '/api/tasks'
        expect(last_response.status).to eq 200
        
        tasks = JSON.parse(last_response.body)
        expect(tasks.length).to eq 1
        expect(tasks[0]["title"]).to eq "Test Task"
      end
    end
    
    describe "GET /api/tasks/:id" do
      it "returns a 404 when task doesn't exist" do
        get '/api/tasks/999'
        expect(last_response.status).to eq 404
      end
      
      it "returns a task when it exists" do
        # Create a test task
        task = Task.create(title: "Test Task", description: "Test Description")
        
        get "/api/tasks/#{task['id']}"
        expect(last_response.status).to eq 200
        
        response_task = JSON.parse(last_response.body)
        expect(response_task["title"]).to eq "Test Task"
        expect(response_task["description"]).to eq "Test Description"
      end
    end
    
    describe "POST /api/tasks" do
      it "creates a new task" do
        task_data = { title: "New Task", description: "New Description" }.to_json
        
        post '/api/tasks', task_data, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq 201
        
        response_task = JSON.parse(last_response.body)
        expect(response_task["title"]).to eq "New Task"
        expect(response_task["description"]).to eq "New Description"
        
        # Verify task was created in database
        tasks = Task.all
        expect(tasks.length).to eq 1
        expect(tasks[0][:title]).to eq "New Task"
      end
    end
    
    describe "PUT /api/tasks/:id" do
      it "returns a 404 when task doesn't exist" do
        task_data = { title: "Updated Task" }.to_json
        
        put '/api/tasks/999', task_data, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq 404
      end
      
      it "updates a task when it exists" do
        # Create a test task
        task = Task.create(title: "Test Task", description: "Test Description")
        
        # Update it
        task_data = { title: "Updated Task" }.to_json
        put "/api/tasks/#{task['id']}", task_data, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq 200
        
        response_task = JSON.parse(last_response.body)
        expect(response_task["title"]).to eq "Updated Task"
        expect(response_task["description"]).to eq "Test Description" # Should remain unchanged
        
        # Verify task was updated in database
        updated_task = Task.find(task['id'])
        expect(updated_task[:title]).to eq "Updated Task"
      end
    end
    
    describe "DELETE /api/tasks/:id" do
      it "returns a 404 when task doesn't exist" do
        delete '/api/tasks/999'
        expect(last_response.status).to eq 404
      end
      
      it "deletes a task when it exists" do
        # Create a test task
        task = Task.create(title: "Test Task", description: "Test Description")
        
        delete "/api/tasks/#{task['id']}"
        expect(last_response.status).to eq 204
        
        # Verify task was deleted from database
        expect(Task.find(task['id'])).to be_nil
      end
    end
  end
  
  describe "Web routes" do
    describe "GET /" do
      it "loads the home page" do
        get '/'
        expect(last_response.status).to eq 200
        expect(last_response.body).to include('Task Manager')
      end
    end
    
    describe "GET /tasks/new" do
      it "loads the new task form" do
        get '/tasks/new'
        expect(last_response.status).to eq 200
        expect(last_response.body).to include('Create New Task')
      end
    end
    
    describe "POST /tasks" do
      it "creates a new task and redirects to home page" do
        post '/tasks', { title: "New Task", description: "New Description" }
        
        expect(last_response.status).to eq 302 # Redirect
        expect(last_response.location).to include('/')
        
        # Verify task was created in database
        tasks = Task.all
        expect(tasks.length).to eq 1
        expect(tasks[0][:title]).to eq "New Task"
      end
    end
  end
end