import React, { useState } from 'react';
import { SyringeIcon } from './components/syringe-icon';
import { BlockchainIcon } from './components/blockchain-icon';
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


type Screen = 'login' | 'register' | 'dashboard' | 'profile' | 'vaccination' | 'success';

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
    vaccine: ''
  });

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

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Simulação de login
    setUser({
      name: 'Dr. Maria Silva',
      cpf: '123.456.789-00',
      clinic: 'Clínica Bem-Estar'
    });
    setCurrentScreen('vaccination');
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

  const handleLogout = () => {
    setUser(null);
    setCurrentScreen('login');
    setLoginForm({ login: '', password: '' });
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
              <SyringeIcon size={48} />
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
        {/* Sidebar */}
        <div className="w-64 p-6" style={{ backgroundColor: '#C89DFF' }}>
          <div className="flex items-center gap-2 mb-8">
            <SyringeIcon size={32} />
            <h1>VaxChain</h1>
          </div>
          
          <nav className="space-y-2">
            <Button
              variant={currentScreen === 'vaccination' ? 'default' : 'ghost'}
              className="w-full justify-start"
              onClick={() => setCurrentScreen('vaccination')}
            >
              <Syringe className="mr-2 h-4 w-4" />
              Registrar Vacinação
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

        {/* Conteúdo principal */}
        <div className="flex-1 p-8">
          {currentScreen === 'dashboard' && (
            <div>
              <h1>Olá, {user.name}!</h1>
              <p className="text-muted-foreground">
                Selecione uma opção no menu para começar.
              </p>
            </div>
          )}

          {currentScreen === 'profile' && (
            <div>
              <h1 className="mb-6">Minhas Informações Cadastrais</h1>
              <Card className="max-w-md">
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

          {currentScreen === 'vaccination' && (
            <div>
              <h1 className="mb-6">Registro de Vacinação</h1>
              <Card className="max-w-md">
                <CardContent className="p-6">
                  <form onSubmit={handleVaccination} className="space-y-4">
                    <div>
                      <Label htmlFor="vaccination-date">Data da Aplicação</Label>
                      <Popover open={datePickerOpen} onOpenChange={setDatePickerOpen}>
                        <PopoverTrigger asChild>
                          <Button
                            variant="outline"
                            className="w-full justify-start text-left"
                          >
                            <CalendarIcon className="mr-2 h-4 w-4" />
                            {vaccinationForm.date.toLocaleDateString('pt-BR', {
                              day: '2-digit',
                              month: 'long',
                              year: 'numeric'
                            })}
                          </Button>
                        </PopoverTrigger>
                        <PopoverContent className="w-auto p-0">
                          <Calendar
                            mode="single"
                            selected={vaccinationForm.date}
                            onSelect={(date) => {
                              if (date) {
                                setVaccinationForm(prev => ({ ...prev, date }));
                                setDatePickerOpen(false);
                              }
                            }}
                            initialFocus
                          />
                        </PopoverContent>
                      </Popover>
                    </div>

                    <div>
                      <Label htmlFor="patient-name">Nome Completo do Paciente</Label>
                      <Input
                        id="patient-name"
                        type="text"
                        value={vaccinationForm.patientName}
                        onChange={(e) => setVaccinationForm(prev => ({ ...prev, patientName: e.target.value }))}
                        required
                      />
                    </div>

                    <div>
                      <Label htmlFor="vaccine">Vacina Aplicada</Label>
                      <Select
                        value={vaccinationForm.vaccine}
                        onValueChange={(value) => setVaccinationForm(prev => ({ ...prev, vaccine: value }))}
                        required
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Selecione a vacina" />
                        </SelectTrigger>
                        <SelectContent>
                          {vaccines.map((vaccine) => (
                            <SelectItem key={vaccine} value={vaccine}>
                              {vaccine}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <Button type="submit" className="w-full" style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}>
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
                    setVaccinationForm({
                      date: new Date(),
                      patientName: '',
                      vaccine: ''
                    });
                  }}
                  className="w-full"
                  style={{ backgroundColor: '#B589FF', borderColor: '#B589FF' }}
                >
                  Registrar Nova Vacina
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