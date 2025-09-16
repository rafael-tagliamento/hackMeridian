import {
	Horizon,
	Keypair,
	TransactionBuilder,
	Networks,
	Contract,
	Address,
	scValToNative,
	nativeToScVal,
	xdr,
} from '@stellar/stellar-sdk';
import { settings } from '../core/config.js';
import { VaccinationTokenCreate, VaccineAttributes } from '../models/vaccination_token.js';

// Endereço do smart contract (deve ser configurado)
const CONTRACT_ID = settings.VACCINE_CONTRACT_ID;

export const createVacToken = async (tokenData: VaccinationTokenCreate): Promise<any> => {
	try {
		const server = new Horizon.Server(settings.STELLAR_NETWORK_URL);
		// Usar a chave admin do contrato para assinar
		const adminKeypair = Keypair.fromSecret(settings.CONTRACT_ADMIN_SECRET_KEY);

		// Usar chave de destino fornecida ou gerar uma aleatória
		let destinationPublicKey: string;

		if (tokenData.destination_public_key) {
			// Validar formato da chave Stellar
			if (!/^G[A-Z2-7]{55}$/.test(tokenData.destination_public_key)) {
				throw new Error('Invalid Stellar destination public key format');
			}
			destinationPublicKey = tokenData.destination_public_key;
		} else {
			// Gerar chave aleatória para o destino
			const destinationKeypair = Keypair.random();
			destinationPublicKey = destinationKeypair.publicKey();
		}

		// Carregar conta admin
		const sourceAccount = await server.loadAccount(adminKeypair.publicKey());

		// Criar instância do contrato
		const contract = new Contract(CONTRACT_ID);

		// Preparar parâmetros para mint_with_attrs
		const destinationAddress = new Address(destinationPublicKey);
		const vaccineName = nativeToScVal(tokenData.name, { type: 'string' });
		const batch = nativeToScVal(tokenData.batch || 'DEFAULT_BATCH', { type: 'string' });
		const expDate = nativeToScVal(
			tokenData.exp_date || Date.now() + 365 * 24 * 60 * 60 * 1000,
			{ type: 'u64' }
		);
		const takenDate = nativeToScVal(tokenData.taken_date || Date.now(), { type: 'u64' });

		// Construir transação para chamar mint_with_attrs
		const transaction = new TransactionBuilder(sourceAccount, {
			fee: '100',
			networkPassphrase: Networks.TESTNET,
		})
			.addOperation(
				contract.call(
					'mint_with_attrs',
					destinationAddress.toScVal(),
					vaccineName,
					batch,
					expDate,
					takenDate
				)
			)
			.setTimeout(30)
			.build();

		// Assinar transação com a chave admin
		transaction.sign(adminKeypair);

		// Submeter para a rede
		const response = await server.submitTransaction(transaction);

		// Por enquanto, não tentaremos extrair o token_id automaticamente
		// Isso pode ser feito posteriormente consultando os eventos da transação
		let tokenId: number | undefined = undefined;

		return {
			status: 'success',
			tx_hash: response.hash,
			destination_public_key: destinationPublicKey,
			token_id: tokenId,
			contract_id: CONTRACT_ID,
		};
	} catch (error: any) {
		console.error('Error creating vaccine token:', error);
		return {
			status: 'error',
			message: error.message,
		};
	}
};

export const verifyTokenOnChain = async (
	tokenId: number,
	contractId: string = CONTRACT_ID
): Promise<boolean> => {
	try {
		// Por enquanto, retornaremos true se o tokenId for um número válido
		// Isso pode ser implementado posteriormente com uma chamada real ao contrato
		return typeof tokenId === 'number' && tokenId > 0;
	} catch (error) {
		console.error('Error verifying token:', error);
		return false;
	}
};
