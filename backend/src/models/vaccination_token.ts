export interface VaccinationToken {
	id: number;
	name: string;
	description: string;
}

export interface VaccinationTokenCreate {
	name: string;
	description: string;
	destination_public_key?: string; // Chave pública do destinatário (opcional)
	batch?: string; // Lote da vacina
	exp_date?: number; // Data de expiração (timestamp)
	taken_date?: number; // Data de aplicação (timestamp)
}

export interface VaccineAttributes {
	name: string;
	batch: string;
	exp_date: number;
	taken_date: number;
}
