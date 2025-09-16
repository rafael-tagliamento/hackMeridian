import React, { useState } from 'react';
import { QRScanner } from './components/qr-scanner';
import { VaccinationLists, mockVaccines } from './components/vaccination-lists';
import { MaterialSelect } from './components/material-select';
import { MaterialNotification } from './components/MaterialNotification';
import { Button } from './components/ui/button';
import { Input } from './components/ui/input';
import { Label } from './components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from './components/ui/card';
import { CheckCircle, User, LogOut, Syringe } from 'lucide-react';
import { QRCodeData } from './utils/stellar-validation';


type Screen = 'login' | 'register' | 'dashboard' | 'profile' | 'scanner' | 'vaccination' | 'success';

interface User {
  name: string;
  cpf: string;
  clinic: string;
}

interface VaccinationRecord {
  date: Date;
  patientName: string;
  vaccine: string;
}

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>("login");
  const [user, setUser] = useState<User | null>(null);
  const [registrationSuccess, setRegistrationSuccess] = useState(false);

  // Estados do formulário de login
  const [loginForm, setLoginForm] = useState({ login: "", password: "" });
  const [isLoading, setIsLoading] = useState(false);

  // Estados para notificações
  const [notification, setNotification] = useState<{
    message: string;
    type: 'error' | 'success' | 'info';
    isVisible: boolean;
  }>({
    message: '',
    type: 'info',
    isVisible: false
  });

  // Estados do formulário de cadastro
  const [registerForm, setRegisterForm] = useState({
    login: "",
    password: "",
    confirmPassword: "",
    name: "",
    cpf: "",
    clinic: "",
  });

  // Estados do formulário de vacinação
  const [vaccinationForm, setVaccinationForm] = useState({
    date: new Date(),
    patientName: "",
    vaccine: "",
    lot: "",
  });

  // Estado para dados escaneados do QR
  const [scannedData, setScannedData] = useState<QRCodeData | null>(null);
  const [scanError, setScanError] = useState<string>('');

  const clinics = [
    "Clínica Bem-Estar",
    "Centro de Saúde Vida",
    "Hospital Central",
    "UBS São João",
    "Clínica Familiar",
  ];

  const vaccines = mockVaccines
    .filter((v) => v.status === "pending" || v.status === "overdue")
    .map((v) => v.name);

  const vaccineLots = [
    "LOTE001-2024",
    "LOTE002-2024",
    "LOTE003-2024",
    "LOTE004-2024",
    "LOTE005-2024",
  ];

  const showNotification = (message: string, type: 'error' | 'success' | 'info') => {
    setNotification({
      message,
      type,
      isVisible: true
    });
  };

  const hideNotification = () => {
    setNotification(prev => ({ ...prev, isVisible: false }));
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    // Simula um delay de autenticação para melhor UX
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Validação para permitir apenas o usuário "maria123"
    if (loginForm.login !== "maria123") {
      showNotification("Dados não conferem. Verifique suas credenciais.", "error");
      setIsLoading(false);
      return;
    }
    
    // Login bem-sucedido para maria123
    setUser({
      name: "Maria Silva",
      cpf: "123.456.789-00",
      clinic: "Clínica Bem-Estar",
    });
    showNotification("Login realizado com sucesso! Bem-vinda, Maria.", "success");
    setTimeout(() => {
      setCurrentScreen("scanner");
    }, 1500);
    setIsLoading(false);
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    if (registerForm.password !== registerForm.confirmPassword) {
      showNotification("As senhas não conferem. Verifique e tente novamente.", "error");
      setIsLoading(false);
      return;
    }
    
    // Simula processamento
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    setRegistrationSuccess(true);
    showNotification("Cadastro realizado com sucesso! Aguarde aprovação.", "success");
    setIsLoading(false);
  };

  const handleVaccination = (e: React.FormEvent) => {
    e.preventDefault();
    
    // TODO: Implementar integração com backend para confirmar a vacina
    // Dados que serão enviados:
    // - scannedData (dados do paciente)
    // - vaccinationForm.vaccine
    // - vaccinationForm.lot
    
    showNotification("Vacina confirmada com sucesso!", "success");
    
    // Reset form and return to scanner
    setTimeout(() => {
      setCurrentScreen("scanner");
      setScannedData(null);
      setScanError('');
      setVaccinationForm({
        date: new Date(),
        patientName: "",
        vaccine: "",
        lot: "",
      });
    }, 2000);
  };

  const handleScanSuccess = (data: QRCodeData) => {
    setScannedData(data);
    setVaccinationForm((prev) => ({
      ...prev,
      patientName: data.name,
      date: new Date(),
      vaccine: "",
      lot: "",
    }));
    setCurrentScreen("vaccination");
  };

  const handleScanError = (error: string) => {
    setScanError(error);
    setScannedData(null);
  };

  const handleLogout = () => {
    setUser(null);
    setCurrentScreen("login");
    setLoginForm({ login: "", password: "" });
    setScannedData(null);
    setScanError('');
    setVaccinationForm({
      date: new Date(),
      patientName: "",
      vaccine: "",
      lot: "",
    });
  };

  // Tela de Login
  if (currentScreen === "login") {
    return (
      <>
        <div className="min-h-screen gradient-bg flex items-center justify-center p-4 page-transition">
          <div className="material-card w-full max-w-md backdrop-blur-sm bg-white/90">
            <div className="p-8">
              <div className="text-center mb-8">
                <div className="flex justify-center mb-6">
                  <img 
                    src="./src/assets/logoroxo.png" 
                    alt="Logo" 
                    className="logo-animation"
                    style={{ width: '80px', height: '80px' }}
                  />
                </div>
                <h1 className="md-headline-small" style={{ color: 'var(--md-primary)' }}>
                  Bem-vinda ao Sistema
                </h1>
                <p className="md-body-medium" style={{ color: 'var(--md-on-surface-variant)' }}>
                  Portal do Aplicador de Vacinas
                </p>
              </div>

              <form onSubmit={handleLogin} className="space-y-6">
                <div className="space-y-2">
                  <label htmlFor="login" className="material-label">
                    Nome de usuário
                  </label>
                  <input
                    id="login"
                    type="text"
                    value={loginForm.login}
                    onChange={(e) =>
                      setLoginForm((prev) => ({ ...prev, login: e.target.value }))
                    }
                    className="material-input w-full"
                    placeholder="Digite seu usuário"
                    required
                    disabled={isLoading}
                  />
                </div>

                <div className="space-y-2">
                  <label htmlFor="password" className="material-label">
                    Senha
                  </label>
                  <input
                    id="password"
                    type="password"
                    value={loginForm.password}
                    onChange={(e) =>
                      setLoginForm((prev) => ({
                        ...prev,
                        password: e.target.value,
                      }))
                    }
                    className="material-input w-full"
                    placeholder="Digite sua senha"
                    required
                    disabled={isLoading}
                  />
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="material-button ripple w-full py-4 flex items-center justify-center gap-2"
                >
                  {isLoading ? (
                    <>
                      <div className="loading-spinner"></div>
                      Entrando...
                    </>
                  ) : (
                    <>
                      <User size={18} />
                      Entrar
                    </>
                  )}
                </button>
              </form>

              <div className="text-center mt-6">
                <p className="md-body-small" style={{ color: 'var(--md-on-surface-variant)' }}>
                  Não tem uma conta?{" "}
                  <button
                    onClick={() => setCurrentScreen("register")}
                    className="font-medium hover:underline transition-all duration-200"
                    style={{ color: 'var(--md-primary)' }}
                    disabled={isLoading}
                  >
                    Cadastre-se aqui
                  </button>
                </p>
              </div>
            </div>
          </div>
        </div>

        <MaterialNotification
          message={notification.message}
          type={notification.type}
          isVisible={notification.isVisible}
          onClose={hideNotification}
        />
      </>
    );
  }

  // Tela de Cadastro
  if (currentScreen === "register") {
    if (registrationSuccess) {
      return (
        <div className="min-h-screen gradient-bg flex items-center justify-center p-4 page-transition">
          <div className="material-card w-full max-w-md success-state backdrop-blur-sm">
            <div className="p-8 text-center">
              <div className="flex justify-center mb-6">
                <div className="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center">
                  <CheckCircle size={32} style={{ color: 'var(--md-success)' }} />
                </div>
              </div>
              <h2 className="md-headline-small mb-4" style={{ color: 'var(--md-on-success-container)' }}>
                Cadastro Realizado!
              </h2>
              <p className="md-body-medium mb-6" style={{ color: 'var(--md-on-success-container)' }}>
                Sua conta foi criada com sucesso. Aguarde a aprovação do administrador 
                para confirmar seu vínculo com a clínica selecionada.
              </p>
              <button
                onClick={() => {
                  setCurrentScreen("login");
                  setRegistrationSuccess(false);
                  setRegisterForm({
                    login: "",
                    password: "",
                    confirmPassword: "",
                    name: "",
                    cpf: "",
                    clinic: "",
                  });
                }}
                className="material-button ripple w-full py-3"
              >
                <User size={18} />
                Voltar ao Login
              </button>
            </div>
          </div>
        </div>
      );
    }

    return (
      <div className="min-h-screen gradient-bg flex items-center justify-center p-4 page-transition">
        <div className="material-card w-full max-w-lg backdrop-blur-sm bg-white/90">
          <div className="p-8">
            <div className="text-center mb-8">
              <div className="flex justify-center mb-4">
                <div className="w-16 h-16 rounded-full bg-blue-100 flex items-center justify-center">
                  <User size={32} style={{ color: 'var(--md-primary)' }} />
                </div>
              </div>
              <h1 className="md-headline-small" style={{ color: 'var(--md-primary)' }}>
                Novo Aplicador
              </h1>
              <p className="md-body-medium" style={{ color: 'var(--md-on-surface-variant)' }}>
                Crie sua conta para acessar o sistema
              </p>
            </div>

            <form onSubmit={handleRegister} className="space-y-6">
              <div className="space-y-6">
                <h3 className="md-title-medium" style={{ color: 'var(--md-primary)' }}>
                  Dados de Acesso
                </h3>
                
                <div className="space-y-2">
                  <label htmlFor="register-login" className="material-label">
                    Nome de usuário
                  </label>
                  <input
                    id="register-login"
                    type="text"
                    value={registerForm.login}
                    onChange={(e) =>
                      setRegisterForm((prev) => ({
                        ...prev,
                        login: e.target.value,
                      }))
                    }
                    className="material-input w-full"
                    placeholder="Digite um nome de usuário"
                    required
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <label htmlFor="register-password" className="material-label">
                      Senha
                    </label>
                    <input
                      id="register-password"
                      type="password"
                      value={registerForm.password}
                      onChange={(e) =>
                        setRegisterForm((prev) => ({
                          ...prev,
                          password: e.target.value,
                        }))
                      }
                      className="material-input w-full"
                      placeholder="Crie uma senha"
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <label htmlFor="confirm-password" className="material-label">
                      Confirmar senha
                    </label>
                    <input
                      id="confirm-password"
                      type="password"
                      value={registerForm.confirmPassword}
                      onChange={(e) =>
                        setRegisterForm((prev) => ({
                          ...prev,
                          confirmPassword: e.target.value,
                        }))
                      }
                      className="material-input w-full"
                      placeholder="Repita a senha"
                      required
                    />
                  </div>
                </div>
              </div>

              <div className="space-y-6">
                <h3 className="md-title-medium" style={{ color: 'var(--md-primary)' }}>
                  Informações Pessoais
                </h3>
                
                <div className="space-y-2">
                  <label htmlFor="name" className="material-label">
                    Nome completo
                  </label>
                  <input
                    id="name"
                    type="text"
                    value={registerForm.name}
                    onChange={(e) =>
                      setRegisterForm((prev) => ({
                        ...prev,
                        name: e.target.value,
                      }))
                    }
                    className="material-input w-full"
                    placeholder="Digite seu nome completo"
                    required
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <label htmlFor="cpf" className="material-label">
                      CPF
                    </label>
                    <input
                      id="cpf"
                      type="text"
                      placeholder="000.000.000-00"
                      value={registerForm.cpf}
                      onChange={(e) =>
                        setRegisterForm((prev) => ({
                          ...prev,
                          cpf: e.target.value,
                        }))
                      }
                      className="material-input w-full"
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="material-label">
                      Clínica
                    </label>
                    <select
                      value={registerForm.clinic}
                      onChange={(e) =>
                        setRegisterForm((prev) => ({
                          ...prev,
                          clinic: e.target.value,
                        }))
                      }
                      className="material-input w-full"
                      required
                    >
                      <option value="">Selecione uma clínica</option>
                      {clinics.map((clinic) => (
                        <option key={clinic} value={clinic}>
                          {clinic}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>

              <div className="flex gap-4 pt-4">
                <button
                  type="button"
                  onClick={() => setCurrentScreen("login")}
                  className="flex-1 py-3 px-6 rounded-full border-2 transition-all duration-200 hover:bg-gray-50"
                  style={{ 
                    borderColor: 'var(--md-outline)',
                    color: 'var(--md-on-surface-variant)'
                  }}
                >
                  Cancelar
                </button>
                
                <button
                  type="submit"
                  disabled={isLoading}
                  className="material-button ripple flex-1 py-3"
                >
                  {isLoading ? (
                    <>
                      <div className="loading-spinner"></div>
                      Cadastrando...
                    </>
                  ) : (
                    <>
                      <CheckCircle size={18} />
                      Cadastrar
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  }

  // Layout com sidebar para as telas autenticadas
  if (user) {
    return (
      <div className="min-h-screen flex">
        {/* Sidebar - aparece no hover */}
        <div className="group relative">
          {/* Área de hover invisível */}
          <div className="w-4 h-full absolute left-0 top-0 z-20"></div>

          {/* Sidebar */}
          <div
            className="fixed left-0 top-0 h-full w-64 p-6 transform -translate-x-56 group-hover:translate-x-0 transition-transform duration-300 ease-in-out z-30 shadow-lg"
            style={{ backgroundColor: "#C89DFF" }}
          >
            <div className="flex items-center gap-2 mb-8">
              <img src="./src/assets/logoroxo.png" alt="Logo" style={{ width: '32px', height: '32px' }} />
              <h1>ImmuneChain</h1>
            </div>

            <nav className="space-y-2">
              <Button
                variant={currentScreen === "scanner" ? "default" : "ghost"}
                className="w-full justify-start"
                onClick={() => setCurrentScreen("scanner")}
              >
                <Syringe className="mr-2 h-4 w-4" />
                Scanner QR Code
              </Button>

              <Button
                variant={currentScreen === "profile" ? "default" : "ghost"}
                className="w-full justify-start"
                onClick={() => setCurrentScreen("profile")}
              >
                <User className="mr-2 h-4 w-4" />
                Minhas Informações
              </Button>
            </nav>

            <div className="mt-8 pt-8 border-t border-sidebar-border">
              <Button
                variant="ghost"
                className="w-full justify-start text-destructive hover:text-destructive"
                onClick={handleLogout}
              >
                <LogOut className="mr-2 h-4 w-4" />
                Sair
              </Button>
            </div>
          </div>

          {/* Indicador visual da sidebar */}
          <div
            className="fixed left-0 top-1/2 transform -translate-y-1/2 w-2 h-20 rounded-r-full opacity-50 group-hover:opacity-100 transition-opacity duration-300"
            style={{ backgroundColor: "#C89DFF" }}
          ></div>
        </div>

        {/* Conteúdo principal */}
        <div className="flex-1 p-8 ml-4">
          {currentScreen === "dashboard" && (
            <div>
              <h1>Olá, {user.name}!</h1>
              <p className="text-muted-foreground">
                Selecione uma opção no menu para começar.
              </p>
            </div>
          )}

          {currentScreen === 'profile' && (
            <div className="flex flex-col items-center justify-center min-h-[80vh]">
              <h1 className="mb-6 text-center">Minhas Informações Cadastrais</h1>
              <Card className="max-w-md w-full">
                <CardContent className="p-6">
                  <div className="space-y-4">
                    <div>
                      <Label>Nome</Label>
                      <p>{user.name}</p>
                    </div>
                    <div>
                      <Label>CPF</Label>
                      <p>{user.cpf}</p>
                    </div>
                    <div>
                      <Label>Clínica Vinculada</Label>
                      <p>{user.clinic}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          )}

          {currentScreen === "scanner" && (
            <div>
              <h1 className="mb-6">Scanner de QR Code do Paciente</h1>
              <QRScanner onScanSuccess={handleScanSuccess} onValidationError={handleScanError} />
            </div>
          )}

          {currentScreen === "vaccination" && (
            <div>
              <h1 className="mb-6">Registro de Vacinação</h1>

              {/* Informações do paciente escaneado */}
              {scannedData && (
                <Card
                  className="mb-6"
                  style={{ backgroundColor: "#FEF2FA", borderColor: "#C89DFF" }}
                >
                  <CardContent className="p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <CheckCircle className="h-5 w-5" style={{ color: '#B589FF' }} />
                      <h3>Dados do Paciente (QR Code Validado)</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <Label>Nome do Paciente</Label>
                        <p>{scannedData.name}</p>
                      </div>
                      <div>
                        <Label>CPF</Label>
                        <p>{scannedData.cpf}</p>
                      </div>
                      <div>
                        <Label>Chave Pública</Label>
                        <p className="truncate" title={scannedData.publicKey}>{scannedData.publicKey.substring(0, 20)}...</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )}

              {/* Histórico de Vacinação */}
              <div className="mb-6">
                <h2 className="mb-4">Histórico de Vacinação do Paciente</h2>
                <VaccinationLists />
              </div>

              {/* Formulário de registro */}
              <Card className="max-w-lg mx-auto">
                <CardContent className="p-6">
                  <form onSubmit={handleVaccination} className="space-y-6">
                    <MaterialSelect
                      label="Vacina Aplicada"
                      placeholder="Selecione a vacina"
                      value={vaccinationForm.vaccine}
                      onValueChange={(value) =>
                        setVaccinationForm((prev) => ({
                          ...prev,
                          vaccine: value,
                        }))
                      }
                      options={vaccines.map((vaccine) => ({
                        value: vaccine,
                        label: vaccine,
                      }))}
                      required
                    />

                    <MaterialSelect
                      label="Lote da Vacina"
                      placeholder="Selecione o lote"
                      value={vaccinationForm.lot}
                      onValueChange={(value) =>
                        setVaccinationForm((prev) => ({ ...prev, lot: value }))
                      }
                      options={vaccineLots.map((lot) => ({
                        value: lot,
                        label: lot,
                      }))}
                      required
                    />

                    <Button
                      type="submit"
                      className="w-full mt-6"
                      style={{
                        backgroundColor: "#B589FF",
                        borderColor: "#B589FF",
                      }}
                    >
                      Confirmar vacina
                    </Button>
                  </form>
                </CardContent>
              </Card>
            </div>
          )}
        </div>
      </div>
    );
  }

  return null;
}
