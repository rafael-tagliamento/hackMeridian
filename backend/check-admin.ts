import { Horizon, Keypair } from '@stellar/stellar-sdk';
import { settings } from './src/core/config.js';

async function checkAdminAccount() {
  try {
    console.log('Checking admin account...');
    console.log('Admin public key:', Keypair.fromSecret(settings.CONTRACT_ADMIN_SECRET_KEY).publicKey());

    const server = new Horizon.Server(settings.STELLAR_NETWORK_URL);
    const adminKeypair = Keypair.fromSecret(settings.CONTRACT_ADMIN_SECRET_KEY);

    const account = await server.loadAccount(adminKeypair.publicKey());
    console.log('Account balances:', account.balances);

    // Verificar se tem XLM suficiente
    const xlmBalance = account.balances.find(b => b.asset_type === 'native');
    if (xlmBalance) {
      console.log('XLM Balance:', xlmBalance.balance);
      const balance = parseFloat(xlmBalance.balance);
      if (balance < 1) {
        console.log('⚠️  WARNING: Account has low balance. Need at least 1 XLM for transaction fees.');
        console.log('Get test XLM from: https://laboratory.stellar.org/#account-creator?network=test');
      } else {
        console.log('✅ Account has sufficient balance');
      }
    }

  } catch (error) {
    console.error('Error checking admin account:', error);
  }
}

checkAdminAccount();
