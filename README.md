# Ruby Test App

A simple Ruby application built with Sinatra that demonstrates basic CRUD operations for managing tasks.

## Features

- RESTful API endpoints for tasks
- Web interface with forms for creating, updating, and deleting tasks
- Persistent storage using SQLite
- Complete test suite using RSpec

## Requirements

- Ruby 2.6+ (recommended 3.0+)
- Bundler
- SQLite3

## Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/ruby-test-app.git
cd ruby-test-app
```

2. Install dependencies:
```
bundle install
```

## Running the Application

Start the application:
```
ruby app.rb
```

The application will be available at http://localhost:4567

## Project Structure

```
├── app.rb                # Main application file
├── Gemfile               # Ruby dependencies
├── models/
│   └── task.rb           # Task model
├── spec/
│   ├── app_spec.rb       # Application tests
│   └── task_spec.rb      # Task model tests
└── views/
    ├── index.erb         # Home page
    ├── new.erb           # New task form
    └── edit.erb          # Edit task form
```

## API Endpoints

- `GET /api/tasks` - Get all tasks
- `GET /api/tasks/:id` - Get a specific task
- `POST /api/tasks` - Create a new task
- `PUT /api/tasks/:id` - Update a task
- `DELETE /api/tasks/:id` - Delete a task

## Web Routes

- `GET /` - Home page with list of tasks
- `GET /tasks/new` - Form to create a new task
- `POST /tasks` - Create a task from form
- `GET /tasks/:id/edit` - Form to edit a task
- `POST /tasks/:id` - Update a task from form
- `POST /tasks/:id/delete` - Delete a task

## Testing

Run the test suite:
```
rspec
```

This will run both the application tests and the model tests.

## Example API Usage

### Get all tasks
```
curl -X GET http://localhost:4567/api/tasks
```

### Create a new task
```
curl -X POST http://localhost:4567/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"New Task","description":"Task Description","completed":false}'
```

### Update a task
```
curl -X PUT http://localhost:4567/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated Task","completed":true}'
```

### Delete a task
```
curl -X DELETE http://localhost:4567/api/tasks/1
```

## License

This project is open source and available under the [MIT License](LICENSE).