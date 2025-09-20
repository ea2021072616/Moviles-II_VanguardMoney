import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/constants/app_sizes.dart";
import "../../../core/constants/app_strings.dart";
import "../../../core/exceptions/error_handler.dart";
import "../viewmodels/auth_provider.dart";

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCurrency = 'S/';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authNotifier = ref.read(authViewModelProvider.notifier);

      if (_isLoginMode) {
        await authNotifier.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _showSuccessSnackBar('Inicio de sesión exitoso');
      } else {
        await authNotifier.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _nameController.text.trim(),
          currency: _selectedCurrency,
        );
        _showSuccessSnackBar('Cuenta creada exitosamente');
      }

      if (mounted) {
        context.go("/home");
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error, StackTrace.current);
      _showErrorSnackBar(errorMessage.message);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final authNotifier = ref.read(authViewModelProvider.notifier);
      await authNotifier.signInWithGoogle();
      _showSuccessSnackBar('Inicio de sesión exitoso');

      if (mounted) {
        context.go("/home");
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error, StackTrace.current);
      _showErrorSnackBar(errorMessage.message);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isLoginMode) {
      if (value == null || value.isEmpty) {
        return 'Por favor confirma tu contraseña';
      }
      if (value != _passwordController.text) {
        return 'Las contraseñas no coinciden';
      }
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!_isLoginMode && (value == null || value.trim().isEmpty)) {
      return 'Por favor ingresa tu nombre';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con formas geométricas inspirado en la imagen
          _buildGeometricBackground(),

          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.spaceM),
                child: _buildMainCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fondo geométrico moderno inspirado en la imagen de referencia
  Widget _buildGeometricBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.98),
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.03),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Círculo grande azul - esquina superior izquierda
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Theme.of(context).colorScheme.primary.withOpacity(0.01),
                  ],
                ),
              ),
            ),
          ),

          // Círculo mediano verde - esquina superior derecha
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.04),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.01),
                  ],
                ),
              ),
            ),
          ),

          // Forma orgánica rosa - centro derecha
          Positioned(
            top: 200,
            right: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(60),
                ),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.03),
                  ],
                ),
              ),
            ),
          ),

          // Círculo pequeño amarillo - centro izquierda
          Positioned(
            top: 300,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.08),
                    Colors.amber.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),

          // Forma triangular coral - esquina inferior derecha
          Positioned(
            bottom: -50,
            right: -50,
            child: ClipPath(
              clipper: _TriangleClipper(),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.error.withOpacity(0.08),
                      Theme.of(context).colorScheme.error.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Forma ondulada lavanda - esquina inferior izquierda
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(100),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(80),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.06),
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.01),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 25,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSizes.spaceXL),
          decoration: BoxDecoration(
            // Efecto glassmorphism sutil
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            border: Border.all(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: AppSizes.spaceXL),
              _buildForm(),
              SizedBox(height: AppSizes.spaceL),
              _buildActionButton(),
              SizedBox(height: AppSizes.spaceM),
              _buildDivider(),
              SizedBox(height: AppSizes.spaceM),
              _buildGoogleSignInButton(),
              SizedBox(height: AppSizes.spaceL),
              _buildModeToggle(),
              if (_isLoginMode) ...[
                SizedBox(height: AppSizes.spaceS),
                _buildForgotPassword(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo moderno con gradiente vibrante
        Container(
          height: 85,
          width: 85,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusL + 2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 42,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        SizedBox(height: AppSizes.spaceL + 4),

        // Título principal con tipografía moderna
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.onSurface,
              Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ],
          ).createShader(bounds),
          child: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(
                context,
              ).colorScheme.surface, // Requerido para ShaderMask
              letterSpacing: -1.2,
              height: 1.0,
              fontSize: 32,
            ),
          ),
        ),

        SizedBox(height: AppSizes.spaceS),

        // Subtítulo elegante con mejor contraste
        Text(
          _isLoginMode ? AppStrings.loginSubtitle : AppStrings.registerSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
            fontSize: 16,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLoginMode) ...[
            _buildTextField(
              controller: _nameController,
              label: AppStrings.nameLabel,
              icon: Icons.person_outline_rounded,
              validator: _validateName,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: AppSizes.spaceM),
          ],

          _buildTextField(
            controller: _emailController,
            label: AppStrings.emailLabel,
            icon: Icons.email_outlined,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),

          SizedBox(height: AppSizes.spaceM),

          _buildTextField(
            controller: _passwordController,
            label: AppStrings.passwordLabel,
            icon: Icons.lock_outline_rounded,
            validator: _validatePassword,
            obscureText: _obscurePassword,
            textInputAction: _isLoginMode
                ? TextInputAction.done
                : TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.blackGrey.withOpacity(0.5),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            onFieldSubmitted: _isLoginMode ? (_) => _submitForm() : null,
          ),

          if (!_isLoginMode) ...[
            SizedBox(height: AppSizes.spaceM),

            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar contraseña',
              icon: Icons.lock_outline_rounded,
              validator: _validateConfirmPassword,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.blackGrey.withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),

            SizedBox(height: AppSizes.spaceM),

            _buildCurrencySelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceM + 2,
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    final currencies = [
      {'code': 'S/', 'name': 'Sol Peruano (S/)'},
      {'code': 'USD', 'name': 'Dólar Americano (USD)'},
      {'code': 'EUR', 'name': 'Euro (EUR)'},
      {'code': 'GBP', 'name': 'Libra Esterlina (GBP)'},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCurrency,
        decoration: InputDecoration(
          labelText: 'Moneda principal',
          prefixIcon: Icon(
            Icons.attach_money_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            size: 22,
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.spaceM,
            vertical: AppSizes.spaceM + 2,
          ),
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
        items: currencies.map((currency) {
          return DropdownMenuItem<String>(
            value: currency['code'],
            child: Text(
              currency['name']!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedCurrency = newValue;
            });
          }
        },
        validator: (value) {
          if (!_isLoginMode && (value == null || value.isEmpty)) {
            return 'Por favor selecciona una moneda';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 12,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                _isLoginMode
                    ? AppStrings.loginButton
                    : AppStrings.registerButton,
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
            thickness: 0.8,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.spaceM),
          child: Text(
            'o continúa con',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
            thickness: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : _signInWithGoogle,
        icon: Container(
          height: 22,
          width: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orange, Colors.yellow, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.g_mobiledata_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 18,
          ),
        ),
        label: Text(AppStrings.continueWithGoogle),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 4,
          shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          _isLoginMode
              ? AppStrings.noAccount + " "
              : AppStrings.hasAccount + " ",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : _toggleMode,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _isLoginMode ? AppStrings.createAccount : AppStrings.signInHere,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: isLoading
          ? null
          : () {
              _showErrorSnackBar(AppStrings.featureInDevelopment);
            },
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        AppStrings.forgotPassword,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          fontSize: 13,
        ),
      ),
    );
  }

  bool get isLoading => ref.watch(authViewModelProvider).isLoading;
}

// Clipper personalizado para crear formas triangulares
class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(0, size.height * 0.7);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
