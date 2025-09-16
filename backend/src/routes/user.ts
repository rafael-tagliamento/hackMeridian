import express, { Request, Response } from 'express';
import { registerUserKYC, getUserByWallet } from '../services/user_service.js';
import { UserKYCCreate } from '../models/user_kyc.js';

const router = express.Router();

router.post('/users/register', async (req: Request, res: Response) => {
	try {
		const data: UserKYCCreate = req.body;
		const result = registerUserKYC(data);
		res.json(result);
	} catch (error: any) {
		res.status(400).json({ error: error.message });
	}
});

router.get('/users/:wallet_address', async (req: Request, res: Response) => {
	try {
		const { wallet_address } = req.params;
		const user = getUserByWallet(wallet_address);

		if (!user) {
			return res.status(404).json({ error: 'User not found' });
		}

		res.json(user);
	} catch (error: any) {
		res.status(500).json({ error: error.message });
	}
});

export default router;
