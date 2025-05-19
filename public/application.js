// Application JavaScript for Ruby Test App

document.addEventListener('DOMContentLoaded', function() {
  // Initialize tooltips if Bootstrap is available
  if (typeof bootstrap !== 'undefined' && bootstrap.Tooltip) {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  }

  // Task completion toggle
  setupTaskToggle();
  
  // Form validation
  setupFormValidation();
  
  // Auto-dismiss alerts
  setupAlertDismissal();
});

// Function to handle task completion toggle
function setupTaskToggle() {
  const statusButtons = document.querySelectorAll('.toggle-status');
  
  statusButtons.forEach(button => {
    button.addEventListener('click', function() {
      const taskId = this.getAttribute('data-task-id');
      const isCompleted = this.getAttribute('data-completed') === 'true';
      
      // If using client-side updates, we could toggle the UI state here
      const taskTitle = document.querySelector(`.task-${taskId} .card-title`);
      const taskDescription = document.querySelector(`.task-${taskId} .card-text`);
      
      if (taskTitle && taskDescription) {
        if (isCompleted) {
          taskTitle.classList.remove('completed');
          taskDescription.classList.remove('completed');
        } else {
          taskTitle.classList.add('completed');
          taskDescription.classList.add('completed');
        }
      }
    });
  });
}

// Function to handle form validation
function setupFormValidation() {
  const forms = document.querySelectorAll('.needs-validation');
  
  forms.forEach(form => {
    form.addEventListener('submit', function(event) {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
      }
      
      form.classList.add('was-validated');
    });
  });
}

// Function to auto-dismiss alerts after 5 seconds
function setupAlertDismissal() {
  const alerts = document.querySelectorAll('.alert-dismissible');
  
  alerts.forEach(alert => {
    setTimeout(() => {
      const closeButton = alert.querySelector('.btn-close');
      if (closeButton) {
        closeButton.click();
      } else {
        alert.style.opacity = '0';
        setTimeout(() => {
          alert.style.display = 'none';
        }, 500);
      }
    }, 5000);
  });
}

// Function to fetch tasks via API (for SPA functionality)
function fetchTasks() {
  fetch('/api/tasks')
    .then(response => response.json())
    .then(tasks => {
      const taskContainer = document.querySelector('#task-container');
      if (taskContainer) {
        taskContainer.innerHTML = '';
        
        if (tasks.length === 0) {
          taskContainer.innerHTML = `
            <div class="alert alert-info">
              No tasks yet. Create one to get started!
            </div>
          `;
        } else {
          tasks.forEach(task => {
            renderTask(taskContainer, task);
          });
        }
      }
    })
    .catch(error => {
      console.error('Error fetching tasks:', error);
    });
}

// Function to render a task card
function renderTask(container, task) {
  const completedClass = task.completed ? 'completed' : '';
  
  const taskHtml = `
    <div class="col-md-4 mb-4 task-${task.id}">
      <div class="card task-card h-100">
        <div class="card-body">
          <h5 class="card-title ${completedClass}">
            ${task.title}
          </h5>
          <p class="card-text ${completedClass}">
            ${task.description || ''}
          </p>
          <div class="text-muted small mb-3">
            Created: ${task.created_at}
          </div>
          <div class="d-flex justify-content-between">
            <a href="/tasks/${task.id}/edit" class="btn btn-sm btn-outline-secondary">Edit</a>
            <button onclick="deleteTask(${task.id})" class="btn btn-sm btn-outline-danger">Delete</button>
          </div>
        </div>
        <div class="card-footer bg-transparent">
          <button 
            onclick="toggleTaskStatus(${task.id}, ${!task.completed})" 
            class="btn btn-sm btn-outline-success w-100 toggle-status"
            data-task-id="${task.id}"
            data-completed="${task.completed}">
            ${task.completed ? 'Mark as Incomplete' : 'Mark as Complete'}
          </button>
        </div>
      </div>
    </div>
  `;
  
  container.insertAdjacentHTML('beforeend', taskHtml);
}

// Function to toggle task status via API
function toggleTaskStatus(taskId, completed) {
  fetch(`/api/tasks/${taskId}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ completed: completed })
  })
    .then(response => {
      if (response.ok) {
        fetchTasks();
      }
    })
    .catch(error => {
      console.error('Error updating task:', error);
    });
}

// Function to delete a task via API
function deleteTask(taskId) {
  if (confirm('Are you sure you want to delete this task?')) {
    fetch(`/api/tasks/${taskId}`, {
      method: 'DELETE'
    })
      .then(response => {
        if (response.ok || response.status === 204) {
          fetchTasks();
        }
      })
      .catch(error => {
        console.error('Error deleting task:', error);
      });
  }
}