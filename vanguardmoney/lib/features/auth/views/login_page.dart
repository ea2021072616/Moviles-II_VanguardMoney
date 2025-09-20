import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_provider.dart';
import '../models/user_profile_model.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCurrency = 'S/';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: AppSizes.animationSlow),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = ref.read(authViewModelProvider.notifier);

    if (_isLoginMode) {
      await authViewModel.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await authViewModel.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _nameController.text.trim(),
        currency: _selectedCurrency,
      );
    }
  }

  Future<void> _handleGoogleAuth() async {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    await authViewModel.signInWithGoogle();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.redCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.greenJade,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el estado de autenticación
    ref.listen(authViewModelProvider, (previous, next) {
      next.whenData((authState) {
        switch (authState) {
          case AuthAuthenticated(:final user):
            _showSuccessSnackBar(
              '${AppStrings.welcomeBack}, ${user.preferredName}!',
            );
            context.go('/home');
            break;
          case AuthError(:final message):
            _showErrorSnackBar(message);
            break;
          default:
            break;
        }
      });
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.value is AuthLoading || authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blueClassic.withOpacity(0.8),
              AppColors.blueLavender.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.spaceL),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.spaceL),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo y título
                          Icon(
                            Icons.trending_up,
                            size: 64,
                            color: AppColors.blueClassic,
                          ),
                          SizedBox(height: AppSizes.spaceM),
                          Text(
                            AppStrings.appName,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blueClassic,
                                ),
                          ),
                          SizedBox(height: AppSizes.spaceS),
                          Text(
                            _isLoginMode
                                ? AppStrings.loginSubtitle
                                : AppStrings.registerSubtitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          SizedBox(height: AppSizes.spaceXL),

                          // Campo de nombre (solo para registro)
                          if (!_isLoginMode) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: AppStrings.nameLabel,
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                                hintText: AppStrings.nameHint,
                              ),
                              validator: FormValidators.validateUsername,
                            ),
                            SizedBox(height: AppSizes.spaceM),

                            // Campo de moneda
                            DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: InputDecoration(
                                labelText: AppStrings.currency,
                                prefixIcon: Icon(
                                  Icons.monetization_on_outlined,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              items: SupportedCurrencies.currencies
                                  .map(
                                    (currency) => DropdownMenuItem(
                                      value: currency['code'],
                                      child: Text(
                                        '${currency['code']} - ${currency['name']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCurrency = value!;
                                });
                              },
                              validator: FormValidators.validateCurrency,
                            ),
                            SizedBox(height: AppSizes.spaceM),
                          ],

                          // Campo de email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: AppStrings.emailLabel,
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: FormValidators.validateEmail,
                          ),
                          SizedBox(height: AppSizes.spaceM),

                          // Campo de contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.passwordLabel,
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(),
                              helperText: _isLoginMode
                                  ? null
                                  : AppStrings.passwordHint,
                              helperMaxLines: 2,
                            ),
                            validator: _isLoginMode
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.validationRequired;
                                    }
                                    return null;
                                  }
                                : FormValidators.validatePassword,
                          ),

                          // Campo de confirmar contraseña (solo para registro)
                          if (!_isLoginMode) ...[
                            SizedBox(height: AppSizes.spaceM),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: AppStrings.confirmPasswordLabel,
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  FormValidators.validateConfirmPassword(
                                    value,
                                    _passwordController.text,
                                  ),
                            ),
                          ],

                          SizedBox(height: AppSizes.spaceXL),

                          // Botón principal (Login/Registro)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleEmailAuth,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusS,
                                  ),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isLoginMode
                                          ? AppStrings.loginButton
                                          : AppStrings.registerButton,
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          SizedBox(height: AppSizes.spaceM),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.spaceM,
                                ),
                                child: Text(
                                  'o',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(height: AppSizes.spaceM),

                          // Botón de Google
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : _handleGoogleAuth,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusS,
                                  ),
                                ),
                              ),
                              icon: Icon(Icons.account_circle, size: 24),
                              label: Text(
                                _isLoginMode
                                    ? AppStrings.continueWithGoogle
                                    : AppStrings.registerWithGoogle,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizes.spaceXL),

                          // Toggle entre login y registro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoginMode
                                    ? AppStrings.noAccount + ' '
                                    : AppStrings.hasAccount + ' ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: isLoading ? null : _toggleMode,
                                child: Text(
                                  _isLoginMode
                                      ? AppStrings.createAccount
                                      : AppStrings.signInHere,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blueClassic,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Olvidé mi contraseña (solo en modo login)
                          if (_isLoginMode) ...[
                            SizedBox(height: AppSizes.spaceXS),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      // TODO: Implementar recuperación de contraseña
                                      _showErrorSnackBar(
                                        'Función en desarrollo',
                                      );
                                    },
                              child: Text(
                                AppStrings.forgotPassword,
                                style: TextStyle(color: AppColors.blueClassic),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
