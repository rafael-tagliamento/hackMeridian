import React, { useState, useEffect } from 'react'
import {
  Container,
  Typography,
  Card,
  CardContent,
  Grid,
  Button,
  Box
} from '@mui/material'
import { useNavigate } from 'react-router-dom'
import ArrowBackIcon from '@mui/icons-material/ArrowBack'

const VaccinationPage = () => {
  const navigate = useNavigate()
  const [vaccinations, setVaccinations] = useState([])

  useEffect(() => {
    // TODO: Fetch vaccination data from backend API
    setVaccinations([
      { id: 1, name: 'COVID-19', status: 'Available' },
      { id: 2, name: 'Influenza', status: 'Available' },
      { id: 3, name: 'Hepatitis B', status: 'Available' }
    ])
  }, [])

  return (
    <Container maxWidth="lg">
      <Box sx={{ mt: 4, mb: 4 }}>
        <Button
          startIcon={<ArrowBackIcon />}
          onClick={() => navigate('/')}
          sx={{ mb: 2 }}
        >
          Back to Home
        </Button>
        <Typography variant="h4" component="h1" gutterBottom>
          Vaccination Management
        </Typography>
        <Grid container spacing={3}>
          {vaccinations.map((vaccination) => (
            <Grid item xs={12} sm={6} md={4} key={vaccination.id}>
              <Card>
                <CardContent>
                  <Typography variant="h6" component="h2">
                    {vaccination.name}
                  </Typography>
                  <Typography color="textSecondary">
                    Status: {vaccination.status}
                  </Typography>
                  <Button
                    variant="outlined"
                    size="small"
                    sx={{ mt: 2 }}
                  >
                    Schedule
                  </Button>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Box>
    </Container>
  )
}

export default VaccinationPage