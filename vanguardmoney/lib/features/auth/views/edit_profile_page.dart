import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/exceptions/error_handler.dart';
import '../constants/auth_constants.dart';
import '../models/edit_profile_model.dart';
import '../models/user_profile_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  late String _selectedCurrency;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = 'S/'; // Valor por defecto válido en AuthConstants
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _initializeForm(UserProfileModel? userProfile) {
    if (!_isInitialized && userProfile != null) {
      _usernameController.text = userProfile.username;
      _selectedCurrency = userProfile.currency;

      // Inicializar el provider con los datos actuales
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(editProfileProvider.notifier)
            .initializeFromUserProfile(userProfile);
      });

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editProfileState = ref.watch(editProfileProvider);
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    // Escuchar cambios en el estado de edición de perfil
    ref.listen(editProfileProvider, (previous, next) {
      if (next.status == EditProfileStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.white),
                SizedBox(width: AppSizes.spaceXS),
                Text('Perfil actualizado exitosamente'),
              ],
            ),
            backgroundColor: AppColors.greenJade,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: AppColors.white,
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
        context.pop(); // Regresar a la página anterior
      } else if (next.status == EditProfileStatus.error) {
        // ✅ ERROR HANDLING CENTRALIZADO - Manejo robusto de errores
        String errorMessage;

        if (next.errorMessage != null) {
          // Si ya tenemos un mensaje de error, verificar si viene del ErrorHandler
          errorMessage = next.errorMessage!;
        } else {
          // Si no hay mensaje, usar ErrorHandler para generar uno consistente
          final handledException = ErrorHandler.handleError(
            Exception('Error desconocido en edición de perfil'),
            StackTrace.current,
          );
          errorMessage = handledException.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.white),
                SizedBox(width: AppSizes.spaceXS),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: AppColors.redCoral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: AppColors.white,
              onPressed: () => _handleSave(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.editProfile,
          style: TextStyle(
            color: AppColors.white,
            fontSize: AppSizes.fontSizeTitleM,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: AppSizes.elevationLow,
        backgroundColor: AppColors.blueClassic,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: userProfileAsync.when(
        data: (userProfile) {
          _initializeForm(userProfile);

          return _buildForm(context, editProfileState, userProfile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          // ✅ ERROR HANDLING CENTRALIZADO - Usar ErrorHandler con AppException
          AppException handledException;

          if (error is AppException) {
            // Si ya es una AppException, mantenerla para preservar el tipo específico
            handledException = error;
          } else {
            // Si no, procesarla con ErrorHandler para convertirla a AppException
            handledException = ErrorHandler.handleError(error, stackTrace);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.redCoral),
                SizedBox(height: AppSizes.spaceM),
                Text(
                  handledException.message, // ✅ Usar mensaje del ErrorHandler
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.spaceXS),
                Text(
                  AppStrings.errorTryAgain,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSizes.spaceXL),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(currentUserProfileProvider),
                  icon: Icon(Icons.refresh),
                  label: Text(AppStrings.retry),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    editProfileState,
    UserProfileModel? userProfile,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.spaceXL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar del usuario
              _buildProfileAvatar(context, userProfile),

              SizedBox(height: AppSizes.spaceXXL),

              // Campo de nombre de usuario
              _buildUsernameField(context, editProfileState),

              SizedBox(height: AppSizes.spaceL),

              // Selector de moneda
              _buildCurrencySelector(context),

              SizedBox(height: AppSizes.spaceL),

              // Información del email (solo lectura)
              _buildEmailField(context, userProfile),

              SizedBox(height: AppSizes.spaceXXL),

              // Mostrar errores de validación
              if (editProfileState.validationErrors.isNotEmpty)
                _buildValidationErrors(
                  context,
                  editProfileState.validationErrors,
                ),

              // Mostrar error general
              if (editProfileState.errorMessage != null)
                _buildErrorMessage(context, editProfileState.errorMessage!),

              // Botón de guardar
              _buildSaveButton(context, editProfileState),

              SizedBox(height: AppSizes.spaceM),

              // Botón de cancelar
              _buildCancelButton(context),

              // Espaciado adicional al final
              SizedBox(height: AppSizes.spaceXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(
    BuildContext context,
    UserProfileModel? userProfile,
  ) {
    final currentUser = ref.watch(currentUserProvider);

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: AppSizes.fabCenterSize,
            backgroundColor: AppColors.blueClassic.withOpacity(0.1),
            child: currentUser?.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      currentUser!.photoUrl!,
                      width: AppSizes.balanceCardHeight,
                      height: AppSizes.balanceCardHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: AppSizes.fabCenterSize,
                          color: AppColors.blueClassic,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: AppSizes.fabCenterSize,
                    color: AppColors.blueClassic,
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: IconButton(
                onPressed: () => _showPhotoOptions(context),
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField(BuildContext context, editProfileState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre de usuario',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'Ingresa tu nombre de usuario',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          validator: FormValidators.validateUsername,
          onChanged: (value) {
            ref.read(editProfileProvider.notifier).updateUsername(value);
          },
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Moneda preferida',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCurrency,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: AuthConstants.currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency['code'],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currency['code']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      currency['name']!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCurrency = value;
              });
              ref.read(editProfileProvider.notifier).updateCurrency(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona una moneda';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, UserProfileModel? userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo electrónico',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: userProfile?.email ?? '',
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          enabled: false,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'El correo electrónico no se puede modificar',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildValidationErrors(BuildContext context, List<String> errors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Errores de validación:',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Text(
                '• $error',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String errorMessage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, editProfileState) {
    final isLoading = editProfileState.status == EditProfileStatus.loading;

    return ElevatedButton(
      onPressed: isLoading ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueClassic,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(vertical: AppSizes.spaceM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        elevation: AppSizes.elevationMedium,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Text(
              'Guardar Cambios',
              style: TextStyle(
                fontSize: AppSizes.fontSizeM,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.pop(),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spaceM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        side: BorderSide(color: AppColors.greyDark),
      ),
      child: Text(
        'Cancelar',
        style: TextStyle(
          fontSize: AppSizes.fontSizeM,
          fontWeight: FontWeight.w600,
          color: AppColors.greyDark,
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(editProfileProvider.notifier)
          .saveProfile();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Perfil actualizado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Volver a la página anterior
        context.pop();
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cambiar foto de perfil',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Tomar foto'),
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Tomar foto');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Elegir de galería'),
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Elegir de galería');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Eliminar foto'),
                    onTap: () {
                      Navigator.pop(context);
                      ref
                          .read(editProfileProvider.notifier)
                          .updatePhotoUrl(null);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Próximamente'),
          ],
        ),
        content: Text(
          'La función "$feature" estará disponible en una próxima actualización.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
