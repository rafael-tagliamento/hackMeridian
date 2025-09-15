# Vaccination Management System
Project for Meridian Hackathon 2025

A comprehensive web application for managing vaccination records, scheduling appointments, and tracking vaccination campaigns.

## 🚀 Features

- **Vaccination Tracking**: Manage vaccination records and inventory
- **Appointment Scheduling**: Book and manage vaccination appointments
- **User Profiles**: Track individual vaccination history
- **Campaign Management**: Organize vaccination campaigns
- **Responsive Design**: Works on desktop and mobile devices

## 🏗️ Project Structure

```
hackMeridian/
├── frontend/          # React frontend application
│   ├── src/
│   │   ├── components/    # Reusable UI components
│   │   ├── pages/        # Page components
│   │   ├── services/     # API services
│   │   ├── utils/        # Utility functions
│   │   ├── styles/       # CSS files
│   │   └── assets/       # Static assets
│   ├── public/           # Public assets
│   └── package.json      # Frontend dependencies
├── backend/           # Node.js backend API
│   ├── src/
│   │   ├── controllers/  # Route controllers
│   │   ├── models/       # Data models
│   │   ├── routes/       # API routes
│   │   ├── middleware/   # Custom middleware
│   │   ├── utils/        # Utility functions
│   │   └── config/       # Configuration files
│   └── package.json      # Backend dependencies
├── docs/              # Project documentation
└── README.md          # This file
```

## 🛠️ Technology Stack

### Frontend
- **React 18** - Modern React with hooks
- **Vite** - Fast build tool and dev server
- **Material-UI** - React components library
- **React Router** - Client-side routing
- **Axios** - HTTP client for API calls

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **MongoDB** - Database (planned)
- **JWT** - Authentication (planned)
- **Helmet** - Security middleware
- **CORS** - Cross-origin resource sharing

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rafael-tagliamento/hackMeridian.git
   cd hackMeridian
   ```

2. **Setup Backend**
   ```bash
   cd backend
   npm install
   cp .env.example .env
   npm run dev
   ```

3. **Setup Frontend** (in a new terminal)
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

4. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - Health check: http://localhost:5000/health

## 📚 API Documentation

The backend provides a RESTful API with the following endpoints:

### Health Check
- `GET /health` - API status

### Vaccinations
- `GET /api/vaccinations` - List all vaccinations
- `GET /api/vaccinations/:id` - Get specific vaccination
- `POST /api/vaccinations` - Create new vaccination

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `GET /api/users/vaccination-history` - Get vaccination history

### Appointments
- `GET /api/appointments` - List appointments
- `POST /api/appointments` - Create appointment
- `PUT /api/appointments/:id` - Update appointment
- `DELETE /api/appointments/:id` - Cancel appointment

## 🧪 Development

### Running Tests
```bash
# Backend tests
cd backend
npm test

# Frontend tests (when available)
cd frontend
npm test
```

### Linting
```bash
# Backend
cd backend
npm run lint

# Frontend
cd frontend
npm run lint
```

## 🚀 Deployment

### Production Build
```bash
# Build frontend
cd frontend
npm run build

# Start backend in production
cd backend
npm start
```

## 📝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

Developed for Meridian Hackathon 2025

## 🔮 Future Enhancements

- User authentication and authorization
- Real-time notifications
- Advanced analytics and reporting
- Mobile app development
- Integration with health systems
- Multi-language support
