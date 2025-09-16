export const initializeDatabase = async () => {
	try {
		console.log('Database initialized successfully (in-memory)');
		return Promise.resolve();
	} catch (error) {
		console.error('Error during database initialization:', error);
		throw error;
	}
};

export const getRepository = <T>(entity: any) => {
	// Simulação de repositório para compatibilidade
	return {
		find: () => [],
		findOne: () => null,
		save: (data: T) => data,
		create: (data: Partial<T>) => data,
	};
};
