const express = require('express')
const router = express.Router()

// Mock user data
let users = [
  {
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+1234567890',
    dateOfBirth: '1990-01-15',
    vaccinationHistory: [
      {
        id: 1,
        vaccinationName: 'COVID-19',
        date: '2023-01-15',
        dose: 1,
        location: 'City Hospital'
      }
    ]
  }
]

// GET /api/users/profile - Get user profile
router.get('/profile', (req, res) => {
  // In a real app, this would get the user from JWT token
  const user = users[0]
  
  res.json({
    success: true,
    data: user
  })
})

// PUT /api/users/profile - Update user profile
router.put('/profile', (req, res) => {
  const { name, email, phone, dateOfBirth } = req.body
  
  // In a real app, this would update the authenticated user
  const user = users[0]
  
  if (name) user.name = name
  if (email) user.email = email
  if (phone) user.phone = phone
  if (dateOfBirth) user.dateOfBirth = dateOfBirth
  
  res.json({
    success: true,
    data: user
  })
})

// GET /api/users/vaccination-history - Get vaccination history
router.get('/vaccination-history', (req, res) => {
  const user = users[0]
  
  res.json({
    success: true,
    data: user.vaccinationHistory || []
  })
})

// POST /api/users/vaccination-history - Add vaccination record
router.post('/vaccination-history', (req, res) => {
  const { vaccinationName, date, dose, location } = req.body
  
  if (!vaccinationName || !date) {
    return res.status(400).json({
      success: false,
      error: 'Vaccination name and date are required'
    })
  }
  
  const user = users[0]
  const newRecord = {
    id: Date.now(),
    vaccinationName,
    date,
    dose: dose || 1,
    location: location || 'Unknown'
  }
  
  if (!user.vaccinationHistory) {
    user.vaccinationHistory = []
  }
  
  user.vaccinationHistory.push(newRecord)
  
  res.status(201).json({
    success: true,
    data: newRecord
  })
})

module.exports = router