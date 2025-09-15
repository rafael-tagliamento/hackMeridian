const express = require('express')
const router = express.Router()

// Mock data for development
const vaccinations = [
  {
    id: 1,
    name: 'COVID-19',
    manufacturer: 'Pfizer-BioNTech',
    doses: 2,
    status: 'Available',
    description: 'mRNA vaccine for COVID-19 prevention'
  },
  {
    id: 2,
    name: 'Influenza',
    manufacturer: 'Sanofi',
    doses: 1,
    status: 'Available',
    description: 'Annual flu vaccine'
  },
  {
    id: 3,
    name: 'Hepatitis B',
    manufacturer: 'GSK',
    doses: 3,
    status: 'Available',
    description: 'Hepatitis B prevention vaccine'
  }
]

// GET /api/vaccinations - Get all vaccinations
router.get('/', (req, res) => {
  res.json({
    success: true,
    data: vaccinations,
    count: vaccinations.length
  })
})

// GET /api/vaccinations/:id - Get vaccination by ID
router.get('/:id', (req, res) => {
  const id = parseInt(req.params.id)
  const vaccination = vaccinations.find(v => v.id === id)
  
  if (!vaccination) {
    return res.status(404).json({
      success: false,
      error: 'Vaccination not found'
    })
  }
  
  res.json({
    success: true,
    data: vaccination
  })
})

// POST /api/vaccinations - Create new vaccination
router.post('/', (req, res) => {
  const { name, manufacturer, doses, status, description } = req.body
  
  if (!name || !manufacturer) {
    return res.status(400).json({
      success: false,
      error: 'Name and manufacturer are required'
    })
  }
  
  const newVaccination = {
    id: vaccinations.length + 1,
    name,
    manufacturer,
    doses: doses || 1,
    status: status || 'Available',
    description: description || ''
  }
  
  vaccinations.push(newVaccination)
  
  res.status(201).json({
    success: true,
    data: newVaccination
  })
})

module.exports = router