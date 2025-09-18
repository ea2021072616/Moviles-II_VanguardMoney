import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/view_model/auth_provider.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer con información del usuario
          _buildDrawerHeader(context, currentUser),

          // Opciones del menú
          _buildMenuItem(
            context,
            Icons.account_circle,
            'Mi Perfil',
            () => context.pushNamed('editProfile'),
          ),
          _buildMenuItem(
            context,
            Icons.attach_money,
            'Configurar Moneda',
            () => _showCurrencyDialog(context),
          ),
          _buildMenuItem(
            context,
            Icons.security,
            'Cambiar Contraseña',
            () => _showComingSoon(context, 'Cambiar Contraseña'),
          ),
          _buildMenuItem(
            context,
            Icons.notifications,
            'Notificaciones',
            () => _showComingSoon(context, 'Configuración de Notificaciones'),
          ),

          const Divider(),

          _buildMenuItem(
            context,
            Icons.help,
            'Ayuda y Soporte',
            () => _showComingSoon(context, 'Ayuda'),
          ),
          _buildMenuItem(
            context,
            Icons.info,
            'Acerca de la App',
            () => _showAboutDialog(context),
          ),

          const Divider(),

          // Cerrar sesión
          _buildMenuItem(
            context,
            Icons.logout,
            'Cerrar Sesión',
            () => _showLogoutDialog(context, ref),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, currentUser) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar del usuario
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: currentUser?.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      currentUser!.photoUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Nombre del usuario
          Flexible(
            child: Text(
              currentUser?.preferredName ?? 'Usuario',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Email del usuario
          Flexible(
            child: Text(
              currentUser?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
      dense: true,
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

  void _showCurrencyDialog(BuildContext context) {
    final currencies = ['S/', '\$', '€', '£', '¥'];
    String selectedCurrency = 'S/';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Seleccionar Moneda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Guardar configuración de moneda
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Moneda cambiada a $selectedCurrency'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'VanguardMoney',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: [
        const Text(
          'VanguardMoney es tu compañero financiero inteligente. '
          'Gestiona tus ingresos, egresos y obtén análisis detallados '
          'para tomar mejores decisiones financieras.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Cerrar Sesión'),
          ],
        ),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar dialog

              // Cerrar sesión
              final authViewModel = ref.read(authViewModelProvider.notifier);
              await authViewModel.signOut();

              // Navegar al login
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
