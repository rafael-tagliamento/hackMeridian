import React from 'react'
import { Container, Typography, Button, Box } from '@mui/material'
import { useNavigate } from 'react-router-dom'
import VaccinesIcon from '@mui/icons-material/Vaccines'

const HomePage = () => {
  const navigate = useNavigate()

  return (
    <Container maxWidth="md">
      <Box sx={{ textAlign: 'center', mt: 8 }}>
        <VaccinesIcon sx={{ fontSize: 80, color: 'primary.main', mb: 2 }} />
        <Typography variant="h2" component="h1" gutterBottom>
          Vaccination Management System
        </Typography>
        <Typography variant="h5" component="h2" gutterBottom color="textSecondary">
          Meridian Hackathon 2025
        </Typography>
        <Typography variant="body1" paragraph sx={{ mt: 4, mb: 4 }}>
          Welcome to the vaccination management system. Track vaccination records,
          schedule appointments, and manage vaccination campaigns efficiently.
        </Typography>
        <Button
          variant="contained"
          size="large"
          onClick={() => navigate('/vaccination')}
          sx={{ mt: 2 }}
        >
          Get Started
        </Button>
      </Box>
    </Container>
  )
}

export default HomePage