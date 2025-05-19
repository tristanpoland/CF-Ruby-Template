class Task
  attr_accessor :id, :title, :description, :completed, :created_at
  
  def initialize(attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @description = attributes[:description]
    @completed = attributes[:completed] || false
    @created_at = attributes[:created_at]
  end
  
  # Find all tasks
  def self.all
    tasks = []
    results = DB.execute("SELECT * FROM tasks ORDER BY created_at DESC")
    
    results.each do |row|
      tasks << {
        id: row["id"],
        title: row["title"],
        description: row["description"],
        completed: row["completed"] == 1,
        created_at: row["created_at"]
      }
    end
    
    tasks
  end
  
  # Find a task by ID
  def self.find(id)
    result = DB.execute("SELECT * FROM tasks WHERE id = ?", id).first
    return nil unless result
    
    {
      id: result["id"],
      title: result["title"],
      description: result["description"],
      completed: result["completed"] == 1,
      created_at: result["created_at"]
    }
  end
  
  # Create a new task
  def self.create(attributes = {})
    DB.execute(
      "INSERT INTO tasks (title, description, completed) VALUES (?, ?, ?)",
      attributes[:title],
      attributes[:description],
      attributes[:completed] ? 1 : 0
    )
    
    task_id = DB.last_insert_row_id
    find(task_id)
  end
  
  # Update a task
  def self.update(id, attributes = {})
    task = find(id)
    return nil unless task
    
    DB.execute(
      "UPDATE tasks SET title = ?, description = ?, completed = ? WHERE id = ?",
      attributes[:title] || task[:title],
      attributes[:description] || task[:description],
      attributes[:completed].nil? ? task[:completed] ? 1 : 0 : attributes[:completed] ? 1 : 0,
      id
    )
    
    find(id)
  end
  
  # Delete a task
  def self.delete(id)
    DB.execute("DELETE FROM tasks WHERE id = ?", id)
    true
  end
  
  # Instance method for updating a task
  def update(attributes = {})
    Task.update(self.id, attributes)
  end
end