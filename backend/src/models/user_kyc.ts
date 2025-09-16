export interface UserKYCBase {
	full_name: string;
	document_id: string;
	id_photo_ref: string;
}

export interface UserKYCCreate extends UserKYCBase {
	wallet_address: string;
}

export interface UserKYCOut extends UserKYCBase {
	id: number;
	wallet_address: string;
	created_at: Date;
}

export interface UserKYCEntity extends UserKYCOut {
	// Para uso interno com banco de dados
}
