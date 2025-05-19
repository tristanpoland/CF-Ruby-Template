ENV['RACK_ENV'] = 'test'

require 'rspec'
require_relative '../models/task'
require 'sqlite3'

# Set up test database
DB = SQLite3::Database.new(':memory:')
DB.results_as_hash = true

# Create the tasks table
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
SQL

RSpec.describe Task do
  before(:each) do
    # Clear the test database before each test
    DB.execute("DELETE FROM tasks")
  end
  
  describe '.all' do
    it 'returns an empty array when no tasks exist' do
      expect(Task.all).to eq([])
    end
    
    it 'returns all tasks when tasks exist' do
      # Create a test task
      DB.execute(
        "INSERT INTO tasks (title, description, completed) VALUES (?, ?, ?)",
        "Test Task", "Test Description", 0
      )
      
      tasks = Task.all
      expect(tasks.length).to eq(1)
      expect(tasks[0][:title]).to eq("Test Task")
      expect(tasks[0][:description]).to eq("Test Description")
      expect(tasks[0][:completed]).to eq(false)
    end
  end
  
  describe '.find' do
    it 'returns nil when task does not exist' do
      expect(Task.find(999)).to be_nil
    end
    
    it 'returns the task when it exists' do
      # Create a test task
      DB.execute(
        "INSERT INTO tasks (title, description, completed) VALUES (?, ?, ?)",
        "Test Task", "Test Description", 0
      )
      
      task_id = DB.last_insert_row_id
      task = Task.find(task_id)
      
      expect(task).not_to be_nil
      expect(task[:title]).to eq("Test Task")
      expect(task[:description]).to eq("Test Description")
      expect(task[:completed]).to eq(false)
    end
  end
  
  describe '.create' do
    it 'creates a new task' do
      task = Task.create(
        title: "New Task",
        description: "New Description",
        completed: true
      )
      
      expect(task).not_to be_nil
      expect(task[:title]).to eq("New Task")
      expect(task[:description]).to eq("New Description")
      expect(task[:completed]).to eq(true)
      
      # Verify task was created in database
      tasks = Task.all
      expect(tasks.length).to eq(1)
      expect(tasks[0][:title]).to eq("New Task")
    end
  end
  
  describe '.update' do
    it 'returns nil when task does not exist' do
      result = Task.update(999, title: "Updated Task")
      expect(result).to be_nil
    end
    
    it 'updates an existing task' do
      # Create a test task
      task = Task.create(
        title: "Test Task",
        description: "Test Description",
        completed: false
      )
      
      # Update it
      updated_task = Task.update(
        task[:id],
        title: "Updated Task",
        completed: true
      )
      
      expect(updated_task).not_to be_nil
      expect(updated_task[:title]).to eq("Updated Task")
      expect(updated_task[:description]).to eq("Test Description") # Should remain unchanged
      expect(updated_task[:completed]).to eq(true)
      
      # Verify task was updated in database
      task_from_db = Task.find(task[:id])
      expect(task_from_db[:title]).to eq("Updated Task")
      expect(task_from_db[:completed]).to eq(true)
    end
  end
  
  describe '.delete' do
    it 'deletes an existing task' do
      # Create a test task
      task = Task.create(
        title: "Test Task",
        description: "Test Description"
      )
      
      # Verify task exists
      expect(Task.find(task[:id])).not_to be_nil
      
      # Delete it
      result = Task.delete(task[:id])
      expect(result).to eq(true)
      
      # Verify task was deleted
      expect(Task.find(task[:id])).to be_nil
    end
  end
end