import { config } from 'dotenv';

config();

export const settings = {
	STELLAR_SECRET_KEY: process.env.STELLAR_SECRET_KEY || '',
	STELLAR_PUBLIC_KEY: process.env.STELLAR_PUBLIC_KEY || '',
	STELLAR_NETWORK_URL: process.env.STELLAR_NETWORK_URL || 'https://horizon-testnet.stellar.org',
	VACCINE_CONTRACT_ID:
		process.env.VACCINE_CONTRACT_ID ||
		'CA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ',
	CONTRACT_ADMIN_SECRET_KEY:
		process.env.CONTRACT_ADMIN_SECRET_KEY || process.env.STELLAR_SECRET_KEY || '',
	DB_URL: process.env.DB_URL || 'sqlite://./vaccine.db',
	PORT: process.env.PORT || 3000,
};
