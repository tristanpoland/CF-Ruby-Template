# Cloud Foundry Deployment Guide

This guide covers deploying the Ruby Test App to Cloud Foundry.

## Prerequisites

- [Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html) installed and configured
- Access to a Cloud Foundry instance (Pivotal Web Services, IBM Cloud, SAP Cloud Platform, etc.)
- A database service available in your Cloud Foundry marketplace (optional)

## Files for Cloud Foundry Deployment

The following files are specifically for Cloud Foundry deployment:

- `manifest.yml` - Deployment manifest
- `.cfignore` - Files to ignore during deployment
- `config/cloud_foundry.rb` - Cloud Foundry configuration
- `config/database.yml` - Database configuration for different environments
- `models/database_connection.rb` - Abstraction for connecting to different database types

## Deployment Steps

### 1. Login to Cloud Foundry

```bash
cf login -a <API_ENDPOINT>
```

Replace `<API_ENDPOINT>` with your Cloud Foundry API endpoint.

### 2. Create a Database Service (Optional but Recommended)

```bash
# List available services in the marketplace
cf marketplace

# Create a database service (e.g., ElephantSQL for PostgreSQL)
cf create-service elephantsql turtle my-db-service

# Or for MySQL
cf create-service cleardb spark my-db-service
```

### 3. Update manifest.yml

Edit the `manifest.yml` file to match your environment:

- Change `ruby-test-app` to your preferred application name
- Adjust memory and instances as needed
- Update the service name if you're using a database
- Update the route to match your Cloud Foundry domain

### 4. Push the Application

```bash
cf push
```

This will deploy the application according to the settings in your manifest.yml file.

### 5. Verify Deployment

```bash
# Check the application status
cf app ruby-test-app

# View application logs
cf logs ruby-test-app --recent
```

Visit the application URL to verify it's working correctly.

## Environment Configuration

The application is designed to run in different environments:

- **Development**: Uses SQLite for simplicity
- **Test**: Uses SQLite with a separate test database
- **Production**: Uses a bound database service if available, or falls back to SQLite

## Database Service Binding

When you bind a database service to your application, Cloud Foundry sets the `VCAP_SERVICES` environment variable containing the connection details. The application automatically detects this and configures the appropriate database connection.

Supported database services:

- **ElephantSQL** (PostgreSQL)
- **ClearDB** (MySQL)
- **Pivotal MySQL**

To bind a database service to your application:

```bash
cf bind-service ruby-test-app my-db-service
cf restage ruby-test-app
```

## Scaling the Application

To scale the application:

```bash
# Scale horizontally (more instances)
cf scale ruby-test-app -i 3

# Scale vertically (more memory)
cf scale ruby-test-app -m 512M
```

## Troubleshooting

### Common Issues

1. **Application Crash**: Check logs with `cf logs ruby-test-app --recent`
2. **Database Connection Issues**: Verify service binding with `cf services`
3. **Route Conflicts**: Ensure the route is unique with `cf routes`

### Restart the Application

```bash
cf restart ruby-test-app
```

### SSH into the Application

For debugging:

```bash
cf ssh ruby-test-app
```

## Additional Resources

- [Cloud Foundry Documentation](https://docs.cloudfoundry.org/)
- [Ruby Buildpack Documentation](https://docs.cloudfoundry.org/buildpacks/ruby/index.html)