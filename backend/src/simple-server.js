const http = require('http')
const url = require('url')

const PORT = process.env.PORT || 5000

// Simple mock data
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
  }
]

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true)
  const path = parsedUrl.pathname
  const method = req.method

  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type')
  res.setHeader('Content-Type', 'application/json')

  // Handle preflight requests
  if (method === 'OPTIONS') {
    res.writeHead(200)
    res.end()
    return
  }

  // Health check
  if (path === '/health' && method === 'GET') {
    res.writeHead(200)
    res.end(JSON.stringify({
      status: 'OK',
      message: 'Vaccination Management API is running',
      timestamp: new Date().toISOString()
    }))
    return
  }

  // Get all vaccinations
  if (path === '/api/vaccinations' && method === 'GET') {
    res.writeHead(200)
    res.end(JSON.stringify({
      success: true,
      data: vaccinations,
      count: vaccinations.length
    }))
    return
  }

  // 404 for unknown routes
  res.writeHead(404)
  res.end(JSON.stringify({
    error: 'Route not found',
    path: path
  }))
})

server.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`)
  console.log(`📱 Environment: ${process.env.NODE_ENV || 'development'}`)
})