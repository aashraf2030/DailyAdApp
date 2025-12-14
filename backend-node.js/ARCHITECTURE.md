# Architecture Documentation

## Overview

This backend follows **Clean Architecture** principles with clear separation of concerns and professional software engineering patterns.

## Architecture Layers

### 1. Routes Layer (`src/routes/`)
- Defines API endpoints
- Maps HTTP methods to controllers
- Applies middleware (auth, validation)

### 2. Controllers Layer (`src/controllers/`)
- Handles HTTP requests and responses
- Validates input
- Calls service methods
- Formats responses

### 3. Services Layer (`src/services/`)
- Contains business logic
- Orchestrates repository calls
- Handles complex operations
- Validates business rules

### 4. Repositories Layer (`src/repositories/`)
- Data access abstraction
- Prisma queries
- Database operations
- No business logic

### 5. Models Layer (Prisma)
- Database schema definition
- Type-safe models
- Relationships

## Design Patterns

### Repository Pattern
- Abstracts data access
- Makes testing easier
- Allows switching databases

### Service Layer Pattern
- Separates business logic from controllers
- Reusable across different interfaces
- Easier to test

### MVC Pattern
- Model: Prisma models
- View: JSON responses
- Controller: Request handlers

### Dependency Injection
- Services instantiate repositories
- Controllers instantiate services
- Loose coupling

## File Structure

```
src/
├── config/          # Configuration (database, env)
├── controllers/     # Request handlers
├── middleware/      # Express middleware
├── repositories/    # Data access
├── routes/          # API routes
├── services/        # Business logic
├── types/           # TypeScript types
├── utils/           # Utilities
└── server.ts        # Entry point
```

## Data Flow

```
Request → Route → Middleware → Controller → Service → Repository → Database
                                                      ↓
Response ← Route ← Controller ← Service ← Repository ← Database
```

## Security

- JWT authentication
- Password hashing (SHA-256)
- Input validation
- Error handling
- CORS configuration
- File upload security

## Error Handling

- Custom error classes
- Centralized error handler
- Proper HTTP status codes
- Error logging

## Validation

- Express-validator
- Input sanitization
- Type checking
- Business rule validation

## Best Practices

1. **Single Responsibility**: Each class/function has one job
2. **DRY**: Don't repeat yourself
3. **Separation of Concerns**: Clear boundaries between layers
4. **Type Safety**: Full TypeScript coverage
5. **Error Handling**: Proper error propagation
6. **Code Organization**: Logical file structure

## Scalability

- Easy to add new features
- Modular architecture
- Testable components
- Clear dependencies

