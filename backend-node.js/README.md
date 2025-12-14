# Backend Node.js - Ads App

Professional Node.js/TypeScript backend for Flutter Ads Application.

## Features

- ✅ Clean Code Architecture
- ✅ Software Engineering Patterns (Repository, Service Layer, MVC)
- ✅ Prisma ORM
- ✅ TypeScript
- ✅ JWT Authentication
- ✅ All Flutter App Endpoints

## Tech Stack

- **Node.js** with **Express**
- **TypeScript**
- **Prisma** ORM
- **JWT** for authentication
- **PostgreSQL** (configurable)

## Project Structure

```
backend-node.js/
├── src/
│   ├── config/          # Configuration files
│   ├── controllers/      # Request handlers
│   ├── middleware/       # Express middleware
│   ├── repositories/     # Data access layer
│   ├── routes/           # API routes
│   ├── services/         # Business logic
│   ├── types/            # TypeScript types
│   ├── utils/            # Utility functions
│   └── server.ts         # Application entry point
├── prisma/
│   └── schema.prisma     # Database schema
└── package.json
```

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and configure:

```env
DATABASE_URL="postgresql://user:password@localhost:5432/ads_app?schema=public"
JWT_SECRET=your-super-secret-jwt-key
PORT=3000
NODE_ENV=development
```

### 3. Setup Database

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations
npm run prisma:migrate
```

### 4. Run Development Server

```bash
npm run dev
```

## API Endpoints

### Authentication (`/api/auth`)
- `POST /register` - Register new user
- `POST /login` - Login user
- `POST /logout` - Logout user
- `POST /profile` - Get user profile
- `POST /is_logged_in` - Check if user is logged in
- `POST /is_admin` - Check if user is admin
- `POST /delete` - Delete user account
- `POST /send_code` - Send verification code
- `POST /verify` - Verify email
- `POST /is_verified` - Check verification status
- `POST /pass_reset` - Request password reset
- `POST /validate_reset` - Validate reset code
- `POST /change_pass` - Change password

### Ads (`/api/ad`)
- `POST /create_ad` - Create new ad
- `POST /edit_ad` - Edit ad
- `POST /get_user_ads` - Get user's ads
- `POST /fetch_cat` - Fetch ads by category
- `POST /renew` - Renew ad

### Views (`/api/view`)
- `POST /watch` - Watch an ad

### Authority (`/api/authority`)
- `POST /default_req` - Get create requests (Admin)
- `POST /renew_req` - Get renewal requests (Admin)
- `POST /money_req` - Get money requests (Admin)
- `POST /my_req` - Get user's requests
- `POST /handle_req` - Handle request (Admin)
- `POST /delete_req` - Delete request
- `POST /leaderboard` - Get leaderboard
- `POST /points_exchange` - Exchange points

### Chat (`/api/chat`)
- `POST /conversation` - Get or create conversation
- `POST /messages` - Get messages
- `POST /send` - Send message
- `GET /admin/conversations` - Get all conversations (Admin)
- `POST /admin/assign` - Assign conversation (Admin)

## Development

### Build

```bash
npm run build
```

### Production

```bash
npm start
```

### Prisma Studio

```bash
npm run prisma:studio
```

## Architecture

### Clean Architecture Layers

1. **Routes** - Define API endpoints
2. **Controllers** - Handle HTTP requests/responses
3. **Services** - Business logic
4. **Repositories** - Data access layer
5. **Models** - Database models (Prisma)

### Design Patterns

- **Repository Pattern** - Abstraction for data access
- **Service Layer** - Business logic separation
- **MVC** - Model-View-Controller
- **Dependency Injection** - Loose coupling

## Security

- JWT token-based authentication
- Password hashing (SHA-256 as per Flutter app)
- Input validation
- Error handling
- CORS configuration

## Notes

- Passwords are hashed using SHA-256 (as Flutter app sends pre-hashed passwords)
- All endpoints match the Flutter app's expected API structure
- UUIDs are used for primary keys
- Soft delete for users (isDeleted flag)

