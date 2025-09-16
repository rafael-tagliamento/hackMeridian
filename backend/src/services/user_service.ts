import { UserKYCEntity, UserKYCCreate, UserKYCOut } from '../models/user_kyc.js';
import { getRepository } from './database_service.js';

// Simulação de banco de dados em memória para simplificar
const users: UserKYCEntity[] = [];
let nextId = 1;

export const registerUserKYC = (data: UserKYCCreate): UserKYCOut => {
	// Verificar se wallet já existe
	const existingUser = users.find(user => user.wallet_address === data.wallet_address);
	if (existingUser) {
		throw new Error('Wallet já registrada');
	}

	// Validar formato da wallet Stellar
	const stellarWalletRegex = /^G[A-Z2-7]{55}$/;
	if (!stellarWalletRegex.test(data.wallet_address)) {
		throw new Error('Invalid Stellar wallet address format');
	}

	const newUser: UserKYCEntity = {
		id: nextId++,
		wallet_address: data.wallet_address,
		full_name: data.full_name,
		document_id: data.document_id.trim(),
		id_photo_ref: data.id_photo_ref,
		created_at: new Date(),
	};

	users.push(newUser);

	return {
		id: newUser.id,
		wallet_address: newUser.wallet_address,
		full_name: newUser.full_name,
		document_id: newUser.document_id,
		id_photo_ref: newUser.id_photo_ref,
		created_at: newUser.created_at,
	};
};

export const getUserByWallet = (wallet_address: string): UserKYCOut | null => {
	const user = users.find(user => user.wallet_address === wallet_address);
	if (!user) {
		return null;
	}

	return {
		id: user.id,
		wallet_address: user.wallet_address,
		full_name: user.full_name,
		document_id: user.document_id,
		id_photo_ref: user.id_photo_ref,
		created_at: user.created_at,
	};
};
