# Backend

This is the backend API for the Vaccination Management System built with Node.js and Express.

## Features

- RESTful API for vaccination management
- User profile management
- Appointment scheduling
- Vaccination history tracking
- Health check endpoint
- CORS enabled for frontend integration

## Development

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

```bash
cd backend
npm install
```

### Configuration

Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

### Running the Development Server

```bash
npm run dev
```

The API will be available at `http://localhost:5000`

### Running in Production

```bash
npm start
```

## Available Scripts

- `npm run dev` - Start development server with nodemon
- `npm start` - Start production server
- `npm test` - Run tests
- `npm run test:watch` - Run tests in watch mode
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint issues

## API Endpoints

### Health Check
- `GET /health` - API health status

### Vaccinations
- `GET /api/vaccinations` - Get all vaccinations
- `GET /api/vaccinations/:id` - Get vaccination by ID
- `POST /api/vaccinations` - Create new vaccination

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `GET /api/users/vaccination-history` - Get vaccination history
- `POST /api/users/vaccination-history` - Add vaccination record

### Appointments
- `GET /api/appointments` - Get all appointments
- `GET /api/appointments/:id` - Get appointment by ID
- `POST /api/appointments` - Create new appointment
- `PUT /api/appointments/:id` - Update appointment
- `DELETE /api/appointments/:id` - Cancel appointment

## Project Structure

```
src/
├── controllers/    # Route controllers
├── models/        # Data models
├── routes/        # API routes
├── middleware/    # Custom middleware
├── utils/         # Utility functions
├── config/        # Configuration files
└── server.js      # Main server file
```