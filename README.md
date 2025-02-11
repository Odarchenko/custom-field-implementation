[![CI](https://github.com/Odarchenko/custom-field-implementation/actions/workflows/ci.yml/badge.svg)](https://github.com/Odarchenko/custom-field-implementation/actions/workflows/ci.yml)
# People Force Test Task

A Rails API application for managing tenants, users, and their properties.

## Requirements

- Ruby 3.2+
- PostgreSQL 14+
- Rails 8.0.1

## Setup

1. Clone the repository:
```bash
git clone https://github.com/Odarchenko/custom-field-implementation
cd custom-field-implementation
```

2. Install dependencies:
```bash
bundle install
```

3. Setup environment variables:
```bash
cp .env.example .env
```

4. Setup database:
```bash
rails db:create
rails db:migrate
```

## Running Tests

To run the RSpec test suite:
```bash
bundle exec rspec
```

## Code Quality

To run Rubocop:
```bash
bundle exec rubocop
```

## API Endpoints

### Update User

Updates user properties and their values.

- **URL**: `/api/v1/users/:id`
- **Method**: `PATCH`
- **Request Parameters**:
```json
{
  "users": {
    "property_values": [
      {
        "name": "property_name",
        "value": "property_value"
      }
    ]
  }
}
```
- **Success Response**:
  - **Code**: 200
  - **Content**:
```json
{
  "user_id": 1
}
```
- **Error Response**:
  - **Code**: 422
  - **Content**:
```json
{
  "errors": ["Error message"]
}
```

### Assumptions

For handling large-scale property updates, the system can be enhanced with an asynchronous processing approach:

1. When dealing with a large number of properties, we can introduce a new table `update_property_values_request` that would store:
   - Input data (property values to be updated)
   - Processing status
   - Errors data
   - Timestamp information

2. The update process would then:
   - Create a record in `update_property_values_request` with the incoming data
   - Return an immediate response with a request ID
   - Process the updates asynchronously via a background job
   - Store any validation errors or processing issues in the errors_data field
   - Allow clients to poll the status of their update request
   - Add endpoint to provide detailed status of the update request

This approach would prevent timeout issues with large datasets and provide better scalability for bulk updates.

### Update Tenant

Updates tenant properties and their configurations.

- **URL**: `/api/v1/tenants/:id`
- **Method**: `PATCH`
- **Request Parameters**:
```json
{
  "properties": {
    "name": "tenant_name",
    "description": "tenant_description",
    "property_params": [
      {
        "name": "property_name",
        "field_type": "string",
        "options": {
          "option1": "value1"
        }
      }
    ]
  }
}
```
- **Success Response**:
  - **Code**: 200
  - **Content**:
```json
{
  "tenant_id": 1
}
```
- **Error Response**:
  - **Code**: 422
  - **Content**:
```json
{
  "errors": ["Error message"]
}
```

## Error Handling

The API returns appropriate HTTP status codes:

- `200 OK` - Request successful
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors

Error responses include detailed messages in the following format:
```json
{"errors" => {"property_values" => ["Property 'property_name' has invalid value"]}}
```

## Development

The application uses:
- RSpec for testing
- Factory Bot for test data generation
- Shoulda Matchers for test assertions
- Database Cleaner for test database maintenance
- Rubocop for code style enforcement
