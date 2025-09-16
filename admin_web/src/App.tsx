import React, { useState } from 'react';
import { BlockchainIcon } from './components/blockchain-icon';
import { QRScanner } from './components/qr-scanner';
import { WebcamScanner } from './components/WebcamScanner'; 
import { VaccinationLists } from './components/vaccination-lists';
import { MaterialSelect } from './components/material-select';
import { Button } from './components/ui/button';
import { Input } from './components/ui/input';
import { Label } from './components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from './components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './components/ui/select';
import { Calendar } from './components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from './components/ui/popover';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from './components/ui/dialog';
import { CalendarIcon, Clock, CheckCircle, User, LogOut, Syringe, Link as LinkIcon } from 'lucide-react';
import { QRCodeSVG } from 'qrcode.react';


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
  const [currentScreen, setCurrentScreen] = useState<Screen>('login');
  const [user, setUser] = useState<User | null>(null);
  const [showQRModal, setShowQRModal] = useState(false);
  const [lastVaccination, setLastVaccination] = useState<VaccinationRecord | null>(null);
  const [registrationSuccess, setRegistrationSuccess] = useState(false);

  // Estados do formulário de login
  const [loginForm, setLoginForm] = useState({ login: '', password: '' });

  // Estados do formulário de cadastro
  const [registerForm, setRegisterForm] = useState({
    login: '',
    password: '',
    confirmPassword: '',
    name: '',
    cpf: '',
    clinic: ''
  });

  // Estados do formulário de vacinação
  const [vaccinationForm, setVaccinationForm] = useState({
    date: new Date(),
    patientName: '',
    vaccine: '',
    lot: ''
  });

  // Estado para dados escaneados do QR
  const [scannedData, setScannedData] = useState<{
    patientName: string;
    date: Date;
  } | null>(null);

  const [datePickerOpen, setDatePickerOpen] = useState(false);

  const clinics = [
    'Clínica Bem-Estar',
    'Centro de Saúde Vida',
    'Hospital Central',
    'UBS São João',
    'Clínica Familiar'
  ];

  const vaccines = [
    'COVID-19 (Pfizer)',
    'COVID-19 (AstraZeneca)',
    'Influenza',
    'Hepatite B',
    'Tétano',
    'Febre Amarela',
    'HPV',
    'Pneumocócica'
  ];

  const vaccineLots = [
    'LOTE001-2024',
    'LOTE002-2024',
    'LOTE003-2024',
    'LOTE004-2024',
    'LOTE005-2024'
  ];

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Simulação de login
    setUser({
      name: 'Dr. Maria Silva',
      cpf: '123.456.789-00',
      clinic: 'Clínica Bem-Estar'
    });
    setCurrentScreen('scanner');
  };

  const handleRegister = (e: React.FormEvent) => {
    e.preventDefault();
    if (registerForm.password !== registerForm.confirmPassword) {
      alert('Senhas não conferem!');
      return;
    }
    setRegistrationSuccess(true);
  };

  const handleVaccination = (e: React.FormEvent) => {
    e.preventDefault();
    const record: VaccinationRecord = {
      date: vaccinationForm.date,
      patientName: vaccinationForm.patientName,
      vaccine: vaccinationForm.vaccine
    };
    setLastVaccination(record);
    setShowQRModal(true);
  };

  const handleScanSuccess = (data: { patientName: string; date: Date }) => {
    setScannedData(data);
    setVaccinationForm(prev => ({
      ...prev,
      patientName: data.patientName,
      date: data.date,
      vaccine: '',
      lot: ''
    }));
    setCurrentScreen('vaccination');
  };

  const handleLogout = () => {
    setUser(null);
    setCurrentScreen('login');
    setLoginForm({ login: '', password: '' });
    setScannedData(null);
    setVaccinationForm({
      date: new Date(),
      patientName: '',
      vaccine: '',
      lot: ''
    });
  };

  const qrCodeData = "Meridian2025"

  const QrCode = () => {
  return (
    <div style={{ padding: '16px', backgroundColor: '#fff', justifyContent: 'center', display: 'flex' }}>
      
      <QRCodeSVG
        value={qrCodeData}
        size={200}
        bgColor="#ffffff"
        fgColor="#000000"
        level="H" // Nível de correção de erro (L, M, Q, H)
      />
    </div>
  );
};

  // Tela de Login
  if (currentScreen === 'login') {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center">
            <div className="flex justify-center mb-4">
              <img src="./src/assets/logoroxo.png" alt="Logo" style={{ width: '100px', height: '100px' }} />
            </div>
            <CardTitle>Login do Aplicador</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <Label htmlFor="login">Login</Label>
                <Input
                  id="login"
                  type="text"
                  value={loginForm.login}
                  onChange={(e) => setLoginForm(prev => ({ ...prev, login: e.target.value }))}
                  required
                />
              </div>
              <div>
                <Label htmlFor="password">Senha</Label>
                <Input
                  id="password"
                  type="password"
                  value={loginForm.password}
                  onChange={(e) => setLoginForm(prev => ({ ...prev, password: e.target.value }))}
                  required
                />
              </div>
              <Button type="submit" className="w-full" style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}>
                Entrar
              </Button>
            </form>
            <p className="text-center mt-4 text-sm">
              Não tem uma conta?{' '}
              <button
                onClick={() => setCurrentScreen('register')}
                className="hover:underline cursor-pointer"
                style={{ color: '#B589FF' }}
              >
                Cadastre-se
              </button>
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Tela de Cadastro
  if (currentScreen === 'register') {
    if (registrationSuccess) {
      return (
        <div className="min-h-screen flex items-center justify-center p-4">
          <Card className="w-full max-w-md">
            <CardContent className="p-8 text-center" style={{ backgroundColor: '#C89DFF' }}>
              <div className="flex justify-center mb-4">
                <Clock size={48} style={{ color: '#B589FF' }} />
              </div>
              <h2 className="mb-4">Cadastro realizado com sucesso!</h2>
              <p className="text-sm text-muted-foreground mb-6">
                Sua conta está pendente de aprovação. Você será notificado quando o sistema
                confirmar seu vínculo com a clínica selecionada.
              </p>
              <Button onClick={() => {
                setCurrentScreen('login');
                setRegistrationSuccess(false);
                setRegisterForm({
                  login: '',
                  password: '',
                  confirmPassword: '',
                  name: '',
                  cpf: '',
                  clinic: ''
                });
              }} style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}>
                Voltar ao Login
              </Button>
            </CardContent>
          </Card>
        </div>
      );
    }

    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle>Cadastro de Novo Aplicador</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleRegister} className="space-y-4">
              <div className="space-y-4">
                <h3 className="text-lg">Acesso</h3>
                <div>
                  <Label htmlFor="register-login">Login</Label>
                  <Input
                    id="register-login"
                    type="text"
                    value={registerForm.login}
                    onChange={(e) => setRegisterForm(prev => ({ ...prev, login: e.target.value }))}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="register-password">Criar Senha</Label>
                  <Input
                    id="register-password"
                    type="password"
                    value={registerForm.password}
                    onChange={(e) => setRegisterForm(prev => ({ ...prev, password: e.target.value }))}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="confirm-password">Confirmar Senha</Label>
                  <Input
                    id="confirm-password"
                    type="password"
                    value={registerForm.confirmPassword}
                    onChange={(e) => setRegisterForm(prev => ({ ...prev, confirmPassword: e.target.value }))}
                    required
                  />
                </div>
              </div>

              <div className="space-y-4">
                <h3 className="text-lg">Informações Pessoais</h3>
                <div>
                  <Label htmlFor="name">Nome Completo</Label>
                  <Input
                    id="name"
                    type="text"
                    value={registerForm.name}
                    onChange={(e) => setRegisterForm(prev => ({ ...prev, name: e.target.value }))}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="cpf">CPF</Label>
                  <Input
                    id="cpf"
                    type="text"
                    placeholder="000.000.000-00"
                    value={registerForm.cpf}
                    onChange={(e) => setRegisterForm(prev => ({ ...prev, cpf: e.target.value }))}
                    required
                  />
                </div>
              </div>

              <div className="space-y-4">
                <h3 className="text-lg">Vínculo Profissional</h3>
                <div>
                  <Label htmlFor="clinic">Selecione a clínica onde trabalha</Label>
                  <Select
                    value={registerForm.clinic}
                    onValueChange={(value) => setRegisterForm(prev => ({ ...prev, clinic: value }))}
                    required
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione uma clínica" />
                    </SelectTrigger>
                    <SelectContent>
                      {clinics.map((clinic) => (
                        <SelectItem key={clinic} value={clinic}>
                          {clinic}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <Button type="submit" className="w-full" style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}>
                Finalizar Cadastro
              </Button>
            </form>
            
            <p className="text-center mt-4 text-sm">
              Já tem uma conta?{' '}
              <button
                onClick={() => setCurrentScreen('login')}
                className="hover:underline cursor-pointer"
                style={{ color: '#B589FF' }}
              >
                Fazer login
              </button>
            </p>
          </CardContent>
        </Card>
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
            style={{ backgroundColor: '#C89DFF' }}
          >
            <div className="flex items-center gap-2 mb-8">
              <img src="./src/assets/logoroxo.png" alt="Logo" style={{ width: '32px', height: '32px' }} />
              <h1>ImmuneChain</h1>
            </div>
            
            <nav className="space-y-2">
              <Button
                variant={currentScreen === 'scanner' ? 'default' : 'ghost'}
                className="w-full justify-start"
                onClick={() => setCurrentScreen('scanner')}
              >
                <Syringe className="mr-2 h-4 w-4" />
                Scanner QR Code
              </Button>
              
              <Button
                variant={currentScreen === 'profile' ? 'default' : 'ghost'}
                className="w-full justify-start"
                onClick={() => setCurrentScreen('profile')}
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
            style={{ backgroundColor: '#C89DFF' }}
          ></div>
        </div>

        {/* Conteúdo principal */}
        <div className="flex-1 p-8 ml-4">
          {currentScreen === 'dashboard' && (
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

          {currentScreen === 'scanner' && (
            <div>
              <h1 className="mb-6">Scanner de QR Code do Paciente</h1>
              <QRScanner onScanSuccess={handleScanSuccess} />
            </div>
          )}

          {currentScreen === 'vaccination' && (
            <div>
              <h1 className="mb-6">Registro de Vacinação</h1>
              
              {/* Informações do paciente escaneado */}
              {scannedData && (
                <Card className="mb-6" style={{ backgroundColor: '#FEF2FA', borderColor: '#C89DFF' }}>
                  <CardContent className="p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <CheckCircle className="h-5 w-5" style={{ color: '#B589FF' }} />
                      <h3>Dados do Paciente (QR Code Escaneado)</h3>
                    </div>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <Label>Nome do Paciente</Label>
                        <p>{scannedData.patientName}</p>
                      </div>
                      <div>
                        <Label>Data de Aplicação</Label>
                        <p>{scannedData.date.toLocaleDateString('pt-BR')}</p>
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
              <Card className="max-w-lg">
                <CardContent className="p-6">
                  <form onSubmit={handleVaccination} className="space-y-6">
                    <MaterialSelect
                      label="Vacina Aplicada"
                      placeholder="Selecione a vacina"
                      value={vaccinationForm.vaccine}
                      onValueChange={(value) => setVaccinationForm(prev => ({ ...prev, vaccine: value }))}
                      options={vaccines.map(vaccine => ({ value: vaccine, label: vaccine }))}
                      required
                    />

                    <MaterialSelect
                      label="Lote da Vacina"
                      placeholder="Selecione o lote"
                      value={vaccinationForm.lot}
                      onValueChange={(value) => setVaccinationForm(prev => ({ ...prev, lot: value }))}
                      options={vaccineLots.map(lot => ({ value: lot, label: lot }))}
                      required
                    />

                    <Button type="submit" className="w-full mt-6" style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}>
                      Gerar QR Code de Atestado
                    </Button>
                  </form>
                </CardContent>
              </Card>
            </div>
          )}

          {/* Modal do QR Code */}
          <Dialog open={showQRModal} onOpenChange={setShowQRModal}>
            <DialogContent className="max-w-md">
              <DialogHeader>
                <DialogTitle className="text-center">Atestado Gerado com Sucesso!</DialogTitle>
              </DialogHeader>
              <div className="text-center space-y-4">
                <div className="center"> <QrCode /></div>
                
                <div className="flex items-start gap-3 text-sm text-left">
                  <BlockchainIcon className="mt-1 flex-shrink-0" size={20} />
                  <p>
                    O paciente deve escanear o QR Code acima para assinar o atestado 
                    digital na plataforma individual e da instituição de saúde.
                  </p>
                </div>

                <Button
                  onClick={() => {
                    setShowQRModal(false);
                    setCurrentScreen('scanner');
                    setScannedData(null);
                    setVaccinationForm({
                      date: new Date(),
                      patientName: '',
                      vaccine: '',
                      lot: ''
                    });
                  }}
                  className="w-full"
                  style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}
                >
                  Escanear Novo Paciente
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>
    );
  }

  return null;
}