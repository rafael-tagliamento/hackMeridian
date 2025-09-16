import express, { Request, Response } from 'express';
import { createVacToken, verifyTokenOnChain } from '../services/stellar_service.js';
import { VaccinationTokenCreate } from '../models/vaccination_token.js';

const router = express.Router();

router.post('/create_vaccine', async (req: Request, res: Response) => {
	try {
		const {
			name,
			description,
			destination_public_key,
			batch,
			exp_date,
			taken_date,
		}: VaccinationTokenCreate = req.body;

		// Validar campos obrigatórios
		if (!name || !description) {
			return res.status(400).json({
				error: 'name and description are required',
			});
		}

		const tokenData: VaccinationTokenCreate = {
			name,
			description,
			destination_public_key,
			batch,
			exp_date,
			taken_date,
		};

		const result = await createVacToken(tokenData);

		res.json(result);
	} catch (error: any) {
		res.status(400).json({ error: error.message });
	}
});

router.get('/verify_vaccine/:token_id', async (req: Request, res: Response) => {
	try {
		const { token_id } = req.params;
		const tokenId = parseInt(token_id, 10);

		if (isNaN(tokenId)) {
			return res.status(400).json({ error: 'Invalid token ID' });
		}

		const isValid = await verifyTokenOnChain(tokenId);
		res.json({ is_valid: isValid, token_id: tokenId });
	} catch (error: any) {
		res.status(500).json({ error: error.message });
	}
});

export default router;
