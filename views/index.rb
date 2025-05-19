<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ruby Test App</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">
  <style>
    .completed { text-decoration: line-through; color: #6c757d; }
    .task-card { transition: all 0.3s ease; }
    .task-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
  </style>
</head>
<body>
  <nav class="navbar navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand" href="/">Ruby Test App</a>
    </div>
  </nav>

  <div class="container my-4">
    <div class="row">
      <div class="col-md-12">
        <div class="d-flex justify-content-between align-items-center mb-4">
          <h1>Task Manager</h1>
          <a href="/tasks/new" class="btn btn-primary">New Task</a>
        </div>
        
        <% if @tasks.empty? %>
          <div class="alert alert-info">
            No tasks yet. Create one to get started!
          </div>
        <% else %>
          <div class="row">
            <% @tasks.each do |task| %>
              <div class="col-md-4 mb-4">
                <div class="card task-card h-100">
                  <div class="card-body">
                    <h5 class="card-title <%= task[:completed] ? 'completed' : '' %>">
                      <%= h task[:title] %>
                    </h5>
                    <p class="card-text <%= task[:completed] ? 'completed' : '' %>">
                      <%= h task[:description] %>
                    </p>
                    <div class="text-muted small mb-3">
                      Created: <%= task[:created_at] %>
                    </div>
                    <div class="d-flex justify-content-between">
                      <div>
                        <a href="/tasks/<%= task[:id] %>/edit" class="btn btn-sm btn-outline-secondary">Edit</a>
                      </div>
                      <div>
                        <form action="/tasks/<%= task[:id] %>/delete" method="post" style="display:inline;">
                          <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure?')">Delete</button>
                        </form>
                      </div>
                    </div>
                  </div>
                  <div class="card-footer bg-transparent">
                    <form action="/tasks/<%= task[:id] %>" method="post" style="display:inline;">
                      <input type="hidden" name="title" value="<%= h task[:title] %>">
                      <input type="hidden" name="description" value="<%= h task[:description] %>">
                      <% if task[:completed] %>
                        <input type="hidden" name="completed" value="0">
                        <button type="submit" class="btn btn-sm btn-outline-success w-100">Mark as Incomplete</button>
                      <% else %>
                        <input type="hidden" name="completed" value="1">
                        <button type="submit" class="btn btn-sm btn-outline-success w-100">Mark as Complete</button>
                      <% end %>
                    </form>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
  </div>

  <footer class="bg-light py-4 mt-4">
    <div class="container text-center text-muted">
      <p>Ruby Test App &copy; <%= Time.now.year %></p>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>