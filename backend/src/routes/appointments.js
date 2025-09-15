const express = require('express')
const router = express.Router()

// Mock appointments data
let appointments = [
  {
    id: 1,
    userId: 1,
    vaccinationId: 1,
    vaccinationName: 'COVID-19',
    date: '2024-02-15',
    time: '10:00',
    location: 'City Hospital',
    status: 'Scheduled'
  },
  {
    id: 2,
    userId: 1,
    vaccinationId: 2,
    vaccinationName: 'Influenza',
    date: '2024-03-01',
    time: '14:30',
    location: 'Community Center',
    status: 'Scheduled'
  }
]

// GET /api/appointments - Get all appointments
router.get('/', (req, res) => {
  res.json({
    success: true,
    data: appointments,
    count: appointments.length
  })
})

// GET /api/appointments/:id - Get appointment by ID
router.get('/:id', (req, res) => {
  const id = parseInt(req.params.id)
  const appointment = appointments.find(a => a.id === id)
  
  if (!appointment) {
    return res.status(404).json({
      success: false,
      error: 'Appointment not found'
    })
  }
  
  res.json({
    success: true,
    data: appointment
  })
})

// POST /api/appointments - Create new appointment
router.post('/', (req, res) => {
  const { vaccinationId, vaccinationName, date, time, location } = req.body
  
  if (!vaccinationId || !date || !time) {
    return res.status(400).json({
      success: false,
      error: 'Vaccination ID, date, and time are required'
    })
  }
  
  const newAppointment = {
    id: appointments.length + 1,
    userId: 1, // In a real app, this would come from the authenticated user
    vaccinationId,
    vaccinationName: vaccinationName || 'Unknown Vaccination',
    date,
    time,
    location: location || 'TBD',
    status: 'Scheduled'
  }
  
  appointments.push(newAppointment)
  
  res.status(201).json({
    success: true,
    data: newAppointment
  })
})

// PUT /api/appointments/:id - Update appointment
router.put('/:id', (req, res) => {
  const id = parseInt(req.params.id)
  const appointmentIndex = appointments.findIndex(a => a.id === id)
  
  if (appointmentIndex === -1) {
    return res.status(404).json({
      success: false,
      error: 'Appointment not found'
    })
  }
  
  const { date, time, location, status } = req.body
  const appointment = appointments[appointmentIndex]
  
  if (date) appointment.date = date
  if (time) appointment.time = time
  if (location) appointment.location = location
  if (status) appointment.status = status
  
  res.json({
    success: true,
    data: appointment
  })
})

// DELETE /api/appointments/:id - Cancel appointment
router.delete('/:id', (req, res) => {
  const id = parseInt(req.params.id)
  const appointmentIndex = appointments.findIndex(a => a.id === id)
  
  if (appointmentIndex === -1) {
    return res.status(404).json({
      success: false,
      error: 'Appointment not found'
    })
  }
  
  appointments.splice(appointmentIndex, 1)
  
  res.json({
    success: true,
    message: 'Appointment cancelled successfully'
  })
})

module.exports = router