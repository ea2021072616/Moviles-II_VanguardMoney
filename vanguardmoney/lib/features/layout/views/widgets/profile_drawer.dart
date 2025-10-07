import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/viewmodels/auth_viewmodel.dart';
import '../../../auth/viewmodels/edit_profile_viewmodel.dart';
import '../../../auth/constants/auth_constants.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          // Header del drawer con información del usuario
          _buildDrawerHeader(context, currentUser),

          // Lista expandible con las opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spaceS,
                vertical: AppSizes.spaceM,
              ),
              children: [
                // Sección de Perfil
                _buildSectionTitle(context, 'Mi Cuenta'),
                _buildMenuItem(
                  context,
                  Icons.account_circle_outlined,
                  Icons.account_circle,
                  AppStrings.editProfile,
                  () => context.push(AppRoutes.editProfile),
                  color: AppColors.blueClassic,
                ),
                _buildMenuItem(
                  context,
                  Icons.attach_money_outlined,
                  Icons.attach_money,
                  'Configurar Moneda',
                  () => _showCurrencyDialog(context, ref),
                  color: AppColors.greenJade,
                ),
                _buildMenuItem(
                  context,
                  Icons.security_outlined,
                  Icons.security,
                  'Cambiar Contraseña',
                  () => _showComingSoon(context, 'Cambiar Contraseña'),
                  color: AppColors.pinkPastel,
                ),

                SizedBox(height: AppSizes.spaceL),

                // Sección de Configuración
                _buildSectionTitle(context, 'Configuración'),
                _buildMenuItem(
                  context,
                  Icons.notifications_outlined,
                  Icons.notifications,
                  'Notificaciones',
                  () => context.push(AppRoutes.notifications),
                  color: AppColors.yellowPastel,
                ),
                _buildMenuItem(
                  context,
                  Icons.palette_outlined,
                  Icons.palette,
                  'Tema y Apariencia',
                  () => _showComingSoon(context, 'Configuración de Tema'),
                  color: AppColors.blueLavender,
                ),

                SizedBox(height: AppSizes.spaceL),

                // Sección de Soporte
                _buildSectionTitle(context, 'Soporte'),
                _buildMenuItem(
                  context,
                  Icons.help_outline,
                  Icons.help,
                  'Ayuda y Soporte',
                  () => _showComingSoon(context, 'Ayuda'),
                  color: AppColors.blueClassic,
                ),
                _buildMenuItem(
                  context,
                  Icons.info_outline,
                  Icons.info,
                  AppStrings.about,
                  () => _showAboutDialog(context),
                  color: AppColors.greenJade,
                ),

                SizedBox(height: AppSizes.spaceXL),

                // Botón de cerrar sesión
                _buildLogoutButton(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header del drawer con información del usuario - Optimizado para evitar overflow
  Widget _buildDrawerHeader(BuildContext context, currentUser) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueClassic, AppColors.blueLavender],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spaceM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar del usuario - Más pequeño
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackGrey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  child: currentUser?.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            currentUser!.photoUrl!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 28,
                                color: AppColors.white,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.person, size: 28, color: AppColors.white),
                ),
              ),
              SizedBox(height: AppSizes.spaceS),

              // Nombre del usuario - Compacto
              Text(
                currentUser?.displayName ?? 'Usuario',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSizeTitleS,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: AppSizes.spaceXS),

              // Email del usuario - Compacto
              Text(
                currentUser?.email ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: AppSizes.fontSizeS,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: AppSizes.spaceS),
            ],
          ),
        ),
      ),
    );
  }

  // Título de sección
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.spaceM,
        bottom: AppSizes.spaceS,
        top: AppSizes.spaceS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.greyDark,
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.fontSizeS,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Item de menú rediseñado con iconos outlined/filled y colores
  Widget _buildMenuItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String title,
    VoidCallback onTap, {
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.spaceXS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        color: Colors.transparent,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Icon(outlinedIcon, color: color, size: AppSizes.iconM),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.blackGrey,
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.fontSizeL,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.greyDark,
          size: AppSizes.iconS,
        ),
        onTap: onTap,
        dense: false,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXS,
        ),
      ),
    );
  }

  // Botón especial para logout
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.spaceM,
        vertical: AppSizes.spaceS,
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, ref),
        icon: Icon(Icons.logout, color: AppColors.white, size: AppSizes.iconS),
        label: Text(
          AppStrings.logout,
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontSizeM,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redCoral,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.spaceL,
            vertical: AppSizes.spaceM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          elevation: AppSizes.elevationMedium,
        ),
      ),
    );
  }

  // Dialogo "Próximamente" mejorado
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        titlePadding: EdgeInsets.all(AppSizes.spaceL),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spaceL,
          vertical: AppSizes.spaceS,
        ),
        actionsPadding: EdgeInsets.all(AppSizes.spaceL),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.spaceS),
              decoration: BoxDecoration(
                color: AppColors.yellowPastel.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.construction,
                color: AppColors.yellowPastel,
                size: AppSizes.iconM,
              ),
            ),
            SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Text(
                'Próximamente',
                style: TextStyle(
                  color: AppColors.blackGrey,
                  fontSize: AppSizes.fontSizeTitleS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'La función "$feature" estará disponible en una próxima actualización.',
          style: TextStyle(
            color: AppColors.greyDark,
            fontSize: AppSizes.fontSizeM,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.blueClassic,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spaceL,
                vertical: AppSizes.spaceS,
              ),
            ),
            child: Text(
              'Entendido',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSizeM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialogo de moneda mejorado
  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.read(currentUserProfileProvider);
    String selectedCurrency = userProfileAsync.value?.currency ?? 'S/';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          titlePadding: EdgeInsets.all(AppSizes.spaceL),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.spaceL,
            vertical: AppSizes.spaceS,
          ),
          actionsPadding: EdgeInsets.all(AppSizes.spaceL),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.greenJade.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: AppColors.greenJade,
                  size: AppSizes.iconM,
                ),
              ),
              SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Text(
                  'Seleccionar Moneda',
                  style: TextStyle(
                    color: AppColors.blackGrey,
                    fontSize: AppSizes.fontSizeTitleS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AuthConstants.currencies.map((currency) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: AppSizes.spaceXS),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    border: Border.all(
                      color: selectedCurrency == currency['code']
                          ? AppColors.greenJade
                          : AppColors.greyLight,
                      width: selectedCurrency == currency['code'] ? 2 : 1,
                    ),
                    color: selectedCurrency == currency['code']
                        ? AppColors.greenJade.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      currency['name']!,
                      style: TextStyle(
                        color: AppColors.blackGrey,
                        fontSize: AppSizes.fontSizeM,
                        fontWeight: selectedCurrency == currency['code']
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    value: currency['code']!,
                    groupValue: selectedCurrency,
                    activeColor: AppColors.greenJade,
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                      });
                    },
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spaceM,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.greyDark,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceL,
                  vertical: AppSizes.spaceS,
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: AppSizes.fontSizeM,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Actualizar la moneda usando el nuevo método específico
                final userProfile = userProfileAsync.value;
                if (userProfile != null &&
                    selectedCurrency != userProfile.currency) {
                  final editNotifier = ref.read(editProfileProvider.notifier);

                  // Usar el método específico para cambiar solo la moneda
                  final success = await editNotifier.saveCurrencyOnly(
                    selectedCurrency,
                  );

                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Moneda cambiada a $selectedCurrency',
                          style: TextStyle(color: AppColors.white),
                        ),
                        backgroundColor: AppColors.greenJade,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                    );
                  } else {
                    // Mostrar error si no se pudo guardar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al cambiar la moneda. Inténtalo de nuevo.',
                          style: TextStyle(color: AppColors.white),
                        ),
                        backgroundColor: AppColors.redCoral,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenJade,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceL,
                  vertical: AppSizes.spaceS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
              ),
              child: Text(
                'Guardar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontSizeM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogo "Acerca de" mejorado
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.blueClassic, AppColors.blueLavender],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueClassic.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.account_balance_wallet,
          color: AppColors.white,
          size: AppSizes.iconL,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.spaceM),
          child: Text(
            AppStrings.appDescription,
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: AppSizes.fontSizeM,
              height: 1.5,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(AppSizes.spaceM),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.blueClassic,
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.spaceS),
              Expanded(
                child: Text(
                  'Versión 1.0.0 - Desarrollado con ❤️',
                  style: TextStyle(
                    color: AppColors.greyDark,
                    fontSize: AppSizes.fontSizeS,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dialogo de logout mejorado
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        titlePadding: EdgeInsets.all(AppSizes.spaceL),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spaceL,
          vertical: AppSizes.spaceS,
        ),
        actionsPadding: EdgeInsets.all(AppSizes.spaceL),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.spaceS),
              decoration: BoxDecoration(
                color: AppColors.redCoral.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.logout,
                color: AppColors.redCoral,
                size: AppSizes.iconM,
              ),
            ),
            SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Text(
                AppStrings.logout,
                style: TextStyle(
                  color: AppColors.blackGrey,
                  fontSize: AppSizes.fontSizeTitleS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.confirmLogout,
          style: TextStyle(
            color: AppColors.greyDark,
            fontSize: AppSizes.fontSizeM,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.greyDark,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spaceL,
                vertical: AppSizes.spaceS,
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: AppSizes.fontSizeM,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar dialog

              // Mostrar loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spaceM),
                      Text(
                        'Cerrando sesión...',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.blueClassic,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Cerrar sesión
              final authViewModel = ref.read(authViewModelProvider.notifier);
              await authViewModel.signOut();

              // Navegar al login
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redCoral,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spaceL,
                vertical: AppSizes.spaceS,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
            child: Text(
              AppStrings.logout,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSizeM,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget separado para el diálogo de notificaciones con manejo de estado propio
class _NotificationsDialogWidget extends StatefulWidget {
  const _NotificationsDialogWidget();

  @override
  State<_NotificationsDialogWidget> createState() =>
      _NotificationsDialogWidgetState();
}

class _NotificationsDialogWidgetState
    extends State<_NotificationsDialogWidget> {
  bool _isLoading = true;
  PermissionStatus? _permissionStatus;
  // Variable adicional para gestionar el estado del toggle independientemente del permiso del sistema
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final status = await Permission.notification.status;
      if (mounted) {
        setState(() {
          _permissionStatus = status;
          // Solo inicializar el estado del toggle si es la primera vez (cuando está cargando)
          if (_isLoading) {
            _notificationsEnabled = status == PermissionStatus.granted;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _permissionStatus = PermissionStatus.denied;
          // Solo cambiar el estado del toggle si es la primera vez
          if (_isLoading) {
            _notificationsEnabled = false;
          }
          _isLoading = false;
        });
      }
      debugPrint('Error al verificar permisos de notificaciones: $e');
    }
  }

  Future<void> _requestNotificationPermission(bool enable) async {
    try {
      // Actualizamos inmediatamente el estado del toggle
      setState(() {
        _notificationsEnabled = enable;
      });

      if (enable) {
        // Solo solicitamos permiso del sistema si queremos activar y no tenemos permiso
        if (_permissionStatus != PermissionStatus.granted) {
          final status = await Permission.notification.request();
          if (mounted) {
            setState(() {
              _permissionStatus = status;
            });
          }
        }
      } else {
        // Para desactivar, abrimos directamente los ajustes del sistema
        if (_permissionStatus == PermissionStatus.granted) {
          // Mostramos una alerta que explique cómo desactivar las notificaciones
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Desactivar notificaciones'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para desactivar completamente las notificaciones a nivel del sistema, sigue estos pasos:',
                    style: TextStyle(
                      color: AppColors.greyDark,
                      fontSize: AppSizes.fontSizeM,
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceM),
                  Container(
                    padding: EdgeInsets.all(AppSizes.spaceS),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Haz clic en "Abrir configuración"',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('2. Selecciona "Notificaciones"'),
                        Text(
                          '3. Desactiva las notificaciones para VanguardMoney',
                        ),
                        Text('4. Vuelve a la aplicación'),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Solo revertir si el usuario cancela y tenía permisos previamente
                    if (_permissionStatus == PermissionStatus.granted) {
                      setState(() {
                        _notificationsEnabled = true;
                      });
                    }
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellowPastel,
                  ),
                  child: Text('Abrir configuración'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al gestionar permisos de notificaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        content: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.yellowPastel),
          ),
        ),
      );
    }

    // Usamos nuestra variable de estado interna para el UI en lugar del permiso del sistema
    final bool notificationsEnabled = _notificationsEnabled;

    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      titlePadding: EdgeInsets.all(AppSizes.spaceL),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.spaceL,
        vertical: AppSizes.spaceS,
      ),
      actionsPadding: EdgeInsets.all(AppSizes.spaceL),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.spaceS),
            decoration: BoxDecoration(
              color: AppColors.yellowPastel.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(
              notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: AppColors.yellowPastel,
              size: AppSizes.iconM,
            ),
          ),
          SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Text(
              'Notificaciones Push',
              style: TextStyle(
                color: AppColors.blackGrey,
                fontSize: AppSizes.fontSizeTitleS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controla si VanguardMoney puede enviarte notificaciones en tu dispositivo.',
              style: TextStyle(
                color: AppColors.greyDark,
                fontSize: AppSizes.fontSizeM,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSizes.spaceL),

            // Información de estado de los permisos del sistema
            if (_permissionStatus != null &&
                _permissionStatus != PermissionStatus.granted &&
                notificationsEnabled)
              Container(
                margin: EdgeInsets.only(bottom: AppSizes.spaceM),
                padding: EdgeInsets.all(AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.redCoral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: Border.all(
                    color: AppColors.redCoral.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.redCoral,
                      size: AppSizes.iconS,
                    ),
                    SizedBox(width: AppSizes.spaceS),
                    Expanded(
                      child: Text(
                        'Las notificaciones están bloqueadas en la configuración del dispositivo. '
                        'Se solicitarán los permisos al guardar.',
                        style: TextStyle(
                          color: AppColors.greyDark,
                          fontSize: AppSizes.fontSizeS,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Si el usuario ya tiene permisos pero los notificaciones están desactivadas en la app, mostrar info
            if (_permissionStatus == PermissionStatus.granted &&
                !notificationsEnabled)
              Container(
                margin: EdgeInsets.only(bottom: AppSizes.spaceM),
                padding: EdgeInsets.all(AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.blueLavender.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: Border.all(
                    color: AppColors.blueLavender.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.blueLavender,
                      size: AppSizes.iconS,
                    ),
                    SizedBox(width: AppSizes.spaceS),
                    Expanded(
                      child: Text(
                        'Para desactivar notificaciones a nivel del sistema, pulsa el interruptor y sigue las instrucciones.',
                        style: TextStyle(
                          color: AppColors.greyDark,
                          fontSize: AppSizes.fontSizeS,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Switch principal para notificaciones push
            Container(
              padding: EdgeInsets.all(AppSizes.spaceM),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: notificationsEnabled
                      ? AppColors.yellowPastel.withOpacity(0.3)
                      : AppColors.greyLight,
                  width: 1,
                ),
                color: notificationsEnabled
                    ? AppColors.yellowPastel.withOpacity(0.08)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSizes.spaceS),
                    decoration: BoxDecoration(
                      color: AppColors.yellowPastel.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      Icons.phone_android,
                      color: AppColors.yellowPastel,
                      size: AppSizes.iconM,
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificaciones del Sistema',
                          style: TextStyle(
                            color: AppColors.blackGrey,
                            fontSize: AppSizes.fontSizeL,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSizes.spaceXS),
                        Text(
                          notificationsEnabled
                              ? 'Recibirás alertas de gastos, límites de presupuesto y recordatorios financieros'
                              : 'No recibirás ninguna notificación en tu dispositivo',
                          style: TextStyle(
                            color: AppColors.greyDark,
                            fontSize: AppSizes.fontSizeS,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: notificationsEnabled,
                    onChanged: (value) async {
                      // Si es true (activar) o si es false (desactivar) pero ya tenemos permiso
                      await _requestNotificationPermission(value);

                      // Solo refrescamos el estado después de volver de los ajustes del sistema
                      // si estamos activando las notificaciones
                      if (value) {
                        await _checkPermissionStatus();
                      }
                    },
                    activeColor: AppColors.yellowPastel,
                    activeTrackColor: AppColors.yellowPastel.withOpacity(0.3),
                    inactiveThumbColor: AppColors.greyLight,
                    inactiveTrackColor: AppColors.greyLight.withOpacity(0.3),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.spaceL),

            // Información adicional
            Container(
              padding: EdgeInsets.all(AppSizes.spaceM),
              decoration: BoxDecoration(
                color: AppColors.blueLavender.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(
                  color: AppColors.blueLavender.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.blueLavender,
                    size: AppSizes.iconS,
                  ),
                  SizedBox(width: AppSizes.spaceS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Qué notificaciones recibirás?',
                          style: TextStyle(
                            color: AppColors.blueLavender,
                            fontSize: AppSizes.fontSizeM,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSizes.spaceXS),
                        Text(
                          '• Alertas cuando excedas tus límites de gastos\n'
                          '• Recordatorios para registrar transacciones\n'
                          '• Confirmaciones de metas financieras alcanzadas\n'
                          '• Resúmenes mensuales importantes',
                          style: TextStyle(
                            color: AppColors.greyDark,
                            fontSize: AppSizes.fontSizeS,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.greyDark,
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.spaceL,
              vertical: AppSizes.spaceS,
            ),
          ),
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: AppSizes.fontSizeM,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Si el usuario desea activar notificaciones pero no tiene permiso
            if (_permissionStatus == PermissionStatus.denied &&
                notificationsEnabled) {
              // Solicitar el permiso
              await _requestNotificationPermission(true);
              await _checkPermissionStatus();
            }

            // Si el usuario desea desactivar y actualmente tiene permisos, mostrarle cómo hacerlo
            if (!notificationsEnabled &&
                _permissionStatus == PermissionStatus.granted) {
              Navigator.of(context).pop(); // Cerrar el diálogo actual
              // Mostrar diálogo para ir a configuración y desactivar notificaciones
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text('Desactivar notificaciones a nivel del sistema'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Para desactivar completamente las notificaciones:'),
                      SizedBox(height: AppSizes.spaceM),
                      Container(
                        padding: EdgeInsets.all(AppSizes.spaceS),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Haz clic en "Abrir configuración"',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('2. Selecciona "Notificaciones"'),
                            Text(
                              '3. Desactiva el interruptor para VanguardMoney',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Más tarde'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        openAppSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellowPastel,
                      ),
                      child: Text('Abrir configuración'),
                    ),
                  ],
                ),
              );
              return;
            }

            // Verificar el estado actual
            if (mounted) {
              // Si quiere activar pero no tiene permiso, mostrar diálogo para ir a configuración
              if (notificationsEnabled &&
                  _permissionStatus != PermissionStatus.granted) {
                Navigator.of(
                  context,
                ).pop(); // Cerrar el diálogo de notificaciones
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Permiso necesario'),
                    content: Text(
                      'Para recibir notificaciones, es necesario otorgar permisos en la configuración del sistema. '
                      '¿Deseas ir a la configuración ahora?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Más tarde'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          openAppSettings();
                        },
                        child: Text('Ir a ajustes'),
                      ),
                    ],
                  ),
                );
              } else {
                // Si todo está correcto, cerramos y mostramos confirmación
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          _permissionStatus == PermissionStatus.granted
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: AppColors.white,
                        ),
                        SizedBox(width: AppSizes.spaceS),
                        Expanded(
                          child: Text(
                            _permissionStatus == PermissionStatus.granted
                                ? 'Notificaciones activadas correctamente'
                                : 'Notificaciones desactivadas correctamente',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor:
                        _permissionStatus == PermissionStatus.granted
                        ? AppColors.greenJade
                        : AppColors.redCoral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.yellowPastel,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.spaceL,
              vertical: AppSizes.spaceS,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: Text(
            'Guardar',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.fontSizeM,
            ),
          ),
        ),
      ],
    );
  }
}
