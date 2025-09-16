# HackMeridian - DEV Branch

## Visão Geral

HackMeridian é uma solução completa que visa modernizar e segurar o gerenciamento de carteiras de vacinação através da tecnologia blockchain. O projeto é dividido em três componentes principais:

  * **Frontend**: Aplicações mobile e web para usuários e administradores, desenvolvidas em Flutter.
  * **Backend**: Uma API robusta desenvolvida com FastAPI que serve como ponte entre o frontend e a blockchain.
  * **Contratos Inteligentes**: Lógica de negócio na blockchain da Stellar, desenvolvida com Soroban, para garantir a imutabilidade e segurança dos registros de vacinação.

## Funcionalidades Principais

### Aplicação do Usuário (`user/frontend`)

  * **Carteira de Vacinação Digital**: Visualize todo o seu histórico de vacinação de forma segura.
  * **Alertas e Notificações**: Receba lembretes sobre próximas doses e vacinas em atraso.
  * **QR Code de Verificação**: Gere um QR Code para validação rápida de sua carteira de vacinação em postos de saúde ou outros locais.

### Painel Administrativo (`admin/frontend/app`)

  * **Gerenciamento de Vacinas**: Adicione novas vacinas ao sistema.
  * **Registro de Pacientes**: Cadastre novos usuários na plataforma.
  * **Aplicação de Vacinas**: Simule a leitura do QR Code de um usuário e registre a aplicação de uma nova vacina, gerando um token NFT na blockchain.

### Backend (`backend`)

  * **API RESTful**: Endpoints para todas as operações do sistema.
  * **Interação com a Blockchain**: Comunicação com a rede Stellar para criar e gerenciar os tokens de vacinação.
  * **Gerenciamento de Banco de Dados**: Armazenamento de informações de usuários e vacinas em um banco de dados local.

### Contratos Inteligentes (`contract`)

  * **NFT de Vacina**: Cada vacina aplicada é registrada como um token não fungível (NFT) na blockchain da Stellar, garantindo a autenticidade e a propriedade do registro para o usuário.
  * **Segurança e Imutabilidade**: Os registros na blockchain são imutáveis e não podem ser alterados, garantindo a integridade do histórico de vacinação.

## Como Executar o Projeto (Ambiente de Desenvolvimento)

### Pré-requisitos

  * **Flutter**: [Instruções de instalação](https://flutter.dev/docs/get-started/install)
  * **Python 3.10+**: [Instruções de instalação](https://www.python.org/downloads/)
  * **Rust & Soroban CLI**: [Instruções de instalação](https://soroban.stellar.org/docs/getting-started/setup)

### 1\. Backend

O backend utiliza FastAPI e SQLAlchemy.

```bash
# Navegue até o diretório do backend
cd backend

# (Recomendado) Crie e ative um ambiente virtual
python -m venv .venv
source .venv/bin/activate  # No Windows: .venv\Scripts\activate

# Instale as dependências
pip install -r requirements.txt

# Execute o servidor de desenvolvimento
uvicorn app.main:app --reload
```

O servidor estará disponível em `http://127.0.0.1:8000`.

### 2\. Frontend

O projeto possui duas aplicações frontend. Execute-as em terminais separados.

#### Aplicação do Usuário

```bash
# Navegue até o diretório do frontend do usuário
cd user/frontend

# Instale as dependências
flutter pub get

# Execute a aplicação
flutter run
```

#### Painel Administrativo

```bash
# Navegue até o diretório do frontend de administração
cd admin/frontend/app

# Instale as dependências
flutter pub get

# Execute a aplicação
flutter run
```

### 3\. Contratos Inteligentes

Os contratos são desenvolvidos com Soroban (Rust).

```bash
# Navegue até o diretório do contrato
cd contract/contracts/hello-world

# Compile o contrato
stellar contract build

# Execute os testes (opcional)
cargo test
```

## Estrutura do Projeto

```
/
├── admin/frontend/app/      # Código do painel administrativo (Flutter)
├── backend/                 # Código do backend (FastAPI)
├── contract/                # Contratos inteligentes (Soroban)
└── user/frontend/           # Código da aplicação do usuário (Flutter)
```
