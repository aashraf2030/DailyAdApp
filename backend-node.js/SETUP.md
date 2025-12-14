# Setup Instructions

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (or MySQL/SQLite)
- npm or yarn

## Step-by-Step Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Database

Create a `.env` file in the root directory:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/ads_app?schema=public"
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000
MAX_FILE_SIZE=10485760
UPLOAD_PATH=./uploads
```

**Important:** Replace the `DATABASE_URL` with your actual database credentials.

### 3. Initialize Database

```bash
# Generate Prisma Client
npm run prisma:generate

# Create database migrations
npm run prisma:migrate

# (Optional) Open Prisma Studio to view/edit data
npm run prisma:studio
```

### 4. Start Development Server

```bash
npm run dev
```

The server will start on `http://localhost:3000`

### 5. Test API

Visit `http://localhost:3000/api/test` to verify the API is working.

## Database Schema

The Prisma schema includes:
- Users
- Sessions
- Ads
- Requests
- Views
- Conversations
- Messages
- Products
- Orders

## API Base URL

All API endpoints are prefixed with `/api`:

- Authentication: `/api/auth/*`
- Ads: `/api/ad/*`
- Views: `/api/view/*`
- Authority: `/api/authority/*`
- Chat: `/api/chat/*`

## Production Deployment

1. Set `NODE_ENV=production` in `.env`
2. Use a strong `JWT_SECRET`
3. Configure proper `CORS_ORIGIN`
4. Build the project: `npm run build`
5. Start with: `npm start`

## Troubleshooting

### Database Connection Issues
- Verify `DATABASE_URL` is correct
- Ensure database server is running
- Check database credentials

### Port Already in Use
- Change `PORT` in `.env`
- Or kill the process using the port

### Prisma Errors
- Run `npm run prisma:generate` again
- Check database connection
- Verify schema is correct

