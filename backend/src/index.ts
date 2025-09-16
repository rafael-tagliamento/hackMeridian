import express from 'express';
import userRouter from './routes/user.js';
import vaccineRouter from './routes/vaccine.js';
import { initializeDatabase } from './services/database_service.js';
import { settings } from './core/config.js';

const app = express();

// Middleware
app.use(express.json());

// Routes
app.use('/api/v1', userRouter);
app.use('/api/v1', vaccineRouter);

// Root endpoint
app.get('/', (req, res) => {
	res.json({
		message: 'Welcome to the Vaccine Verification API. Visit /docs for documentation.',
		version: '1.0.0',
	});
});

// Initialize database and start server
const startServer = async () => {
	try {
		await initializeDatabase();

		const PORT = settings.PORT;
		app.listen(PORT, () => {
			console.log(`🚀 Servidor Express rodando na porta ${PORT}`);
			console.log(`📚 Documentação disponível em http://localhost:${PORT}/docs`);
		});
	} catch (error) {
		console.error('Erro ao iniciar o servidor:', error);
		process.exit(1);
	}
};

startServer();
