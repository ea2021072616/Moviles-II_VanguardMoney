import 'package:flutter/material.dart';

void main() {
  runApp(const VanguardMoneyApp());
}

// App theme: switch from orange to a fresh blue palette
const Color kPrimary = Color(0xFF1976D2); // Blue 700
const Color kOnPrimary = Colors.white;
const Color kBg = Color(0xFFF5F7FB);

class VanguardMoneyApp extends StatelessWidget {
  const VanguardMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        primary: kPrimary,
        onPrimary: kOnPrimary,
        background: kBg,
      ),
      scaffoldBackgroundColor: kBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimary,
        foregroundColor: kOnPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E6EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E6EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kOnPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vanguard Money',
      theme: theme,
      home: const SplashScreen(),
      routes: {
        StartOptionScreen.route: (_) => const StartOptionScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        RegisterScreen.route: (_) => const RegisterScreen(),
      },
    );
  }
}

// 1) Splash - "Inicio logo"
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(StartOptionScreen.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Icon(Icons.show_chart, size: 96, color: kPrimary)),
    );
  }
}

// 2) Inicio opción - logo + botón "Iniciar"
class StartOptionScreen extends StatelessWidget {
  static const route = '/start-option';
  const StartOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: const Color(0xFFF2F6FF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.show_chart, size: 96, color: kPrimary),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, LoginScreen.route),
                child: const Text('Iniciar'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// 3) Bienvenida / Login
class LoginScreen extends StatefulWidget {
  static const route = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: 'Bienvenido'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Correo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'example@example.com',
                        ),
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : 'Ingresa un correo válido',
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Contraseña',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v != null && v.length >= 6
                            ? null
                            : 'Mínimo 6 caracteres',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // ... handle login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Iniciando sesión...'),
                              ),
                            );
                          }
                        },
                        child: const Text('Iniciar Sesión'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, RegisterScreen.route),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: kPrimary),
                          foregroundColor: kPrimary,
                          backgroundColor: Colors.white,
                        ),
                        child: const Text('Registrarse'),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Iniciar sesión con:',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                _SocialCircle(icon: Icons.g_mobiledata),
                                SizedBox(width: 12),
                                _SocialCircle(icon: Icons.facebook),
                                SizedBox(width: 12),
                                _SocialCircle(icon: Icons.apple),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4) Crear Cuenta / Register
class RegisterScreen extends StatefulWidget {
  static const route = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: 'Crear Cuenta'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Nombre Completo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Martín Pérez',
                        ),
                        validator: (v) => v != null && v.trim().isNotEmpty
                            ? null
                            : 'Campo requerido',
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'example@example.com',
                        ),
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : 'Correo inválido',
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure1,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure1
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure1 = !_obscure1),
                          ),
                        ),
                        validator: (v) => v != null && v.length >= 6
                            ? null
                            : 'Mínimo 6 caracteres',
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Confirm Password',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscure2,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure2 = !_obscure2),
                          ),
                        ),
                        validator: (v) => v == _passCtrl.text
                            ? null
                            : 'Las contraseñas no coinciden',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // ... handle register
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Creando cuenta...'),
                              ),
                            );
                          }
                        },
                        child: const Text('Crear Cuenta'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ya tienes una cuenta? Inicia sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shared header like the mockup (colored curved top area)
class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kOnPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.show_chart, color: kOnPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final IconData icon;
  const _SocialCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E6EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: kPrimary),
    );
  }
}
