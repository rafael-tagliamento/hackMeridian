#![no_std]

use soroban_sdk::{
    contract, contracterror, contractimpl, contracttype, panic_with_error,
    symbol_short, Address, Env, String, Symbol,
};

// -------------------------
// STORAGE KEYS
// -------------------------

const NEXT_ID_SYM: Symbol = symbol_short!("next_id");
const NAME_SYM: Symbol = symbol_short!("name");
const SYMBOL_SYM: Symbol = symbol_short!("symbol");
const ADMIN_SYM: Symbol = symbol_short!("admin");

// Contador de IDs
fn read_next_id(e: &Env) -> u128 {
    e.storage()
        .persistent()
        .get::<Symbol, u128>(&NEXT_ID_SYM)
        .unwrap_or(0)
}
fn write_next_id(e: &Env, val: u128) {
    e.storage().persistent().set(&NEXT_ID_SYM, &val);
}

// Owner de cada token
fn owner_key(token_id: u128) -> (Symbol, u128) {
    (symbol_short!("owner"), token_id)
}
fn read_owner(e: &Env, token_id: u128) -> Option<Address> {
    e.storage().persistent().get(&owner_key(token_id))
}
fn write_owner(e: &Env, token_id: u128, owner: &Address) {
    e.storage().persistent().set(&owner_key(token_id), owner);
}

// Estrutura de atributos da vacina
#[contracttype]
#[derive(Clone, Debug)]
pub struct VaccineAttrs {
    pub name: String,
    pub batch: String,
    pub exp_date: u64,
    pub taken_date: u64,
}

// Storage de atributos
fn attrs_key(token_id: u128) -> (Symbol, u128) {
    (symbol_short!("attrs"), token_id)
}

// -------------------------
// ERROS
// -------------------------

#[contracterror]
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u32)]
pub enum Error {
    TokenNotFound = 1,
    NotOwner = 2,
    NotAdmin = 3,
}

// -------------------------
// CONTRATO NFT DE VACINA
// -------------------------

#[contract]
pub struct VaccineNftContract;

#[contractimpl]
impl VaccineNftContract {
    /// Inicializa contrato NFT com nome, símbolo e admin
    pub fn initialize(e: Env, admin: Address, name: String, symbol: String) {
        if e.storage().persistent().has(&ADMIN_SYM) {
            // já inicializado
            return;
        }
        e.storage().persistent().set(&ADMIN_SYM, &admin);
        e.storage().persistent().set(&NAME_SYM, &name);
        e.storage().persistent().set(&SYMBOL_SYM, &symbol);
        write_next_id(&e, 0);
    }

    /// Lê admin
    pub fn admin(e: Env) -> Address {
        e.storage()
            .persistent()
            .get(&ADMIN_SYM)
            .unwrap()
    }

    /// Lê dono do token
    pub fn owner_of(e: Env, token_id: u128) -> Option<Address> {
        read_owner(&e, token_id)
    }

    /// Mint com atributos, gerando token_id automaticamente
    pub fn mint_with_attrs(
        e: Env,
        to: Address,
        vaccine_name: String,
        batch: String,
        exp_date: u64,
        taken_date: u64,
    ) -> u128 {
        // Somente admin pode mintar
        let admin: Address = e.storage().persistent().get(&ADMIN_SYM).unwrap();
        admin.require_auth();

        // Incrementa contador
        let mut id = read_next_id(&e);
        id += 1;
        write_next_id(&e, id);

        // Define owner
        write_owner(&e, id, &to);

        // Salvar atributos customizados
        let attrs = VaccineAttrs {
            name: vaccine_name,
            batch,
            exp_date,
            taken_date,
        };
        e.storage().persistent().set(&attrs_key(id), &attrs);

        id
    }

    /// Lê atributos customizados
    pub fn get_attrs(e: Env, token_id: u128) -> VaccineAttrs {
        e.storage()
            .persistent()
            .get(&attrs_key(token_id))
            .unwrap_or_else(|| panic_with_error!(&e, Error::TokenNotFound))
    }

    /// Atualiza atributos (somente owner)
    pub fn update_attrs(
        e: Env,
        caller: Address,
        token_id: u128,
        vaccine_name: String,
        batch: String,
        exp_date: u64,
        taken_date: u64,
    ) {
        let owner = read_owner(&e, token_id)
            .unwrap_or_else(|| panic_with_error!(&e, Error::TokenNotFound));

        if caller != owner {
            panic_with_error!(&e, Error::NotOwner);
        }
        caller.require_auth();

        let attrs = VaccineAttrs {
            name: vaccine_name,
            batch,
            exp_date,
            taken_date,
        };
        e.storage().persistent().set(&attrs_key(token_id), &attrs);
    }

    /// Transferência simples
    pub fn transfer(e: Env, from: Address, to: Address, token_id: u128) {
        let owner = read_owner(&e, token_id)
            .unwrap_or_else(|| panic_with_error!(&e, Error::TokenNotFound));

        if owner != from {
            panic_with_error!(&e, Error::NotOwner);
        }
        from.require_auth();

        write_owner(&e, token_id, &to);
    }
}
