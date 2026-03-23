import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/core/themes/theme_provider.dart';
import 'package:servizone_app/main.dart'; // To access global themeProvider
import 'package:servizone_app/presentation/views/client/profile/edit_profile_screen.dart';
import 'package:servizone_app/presentation/views/client/profile/change_password_screen.dart';

import 'package:servizone_app/presentation/views/common/booking_history_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ClientProfileScreen({super.key, required this.onLogout});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    if (name != null && mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  String _getInitials(String name) {
    String trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    List<String> parts = trimmed.split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + (parts[1].isNotEmpty ? parts[1].substring(0, 1) : '')).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: configBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Configuraciones',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(_userName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '@$_userName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: darkGray,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Información personal'),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              title: 'Editar información personal',
              color: primaryBlue,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.lock_reset_rounded,
              title: 'Cambiar contraseña',
              color: primaryBlue,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Preferencias'),
            ListenableBuilder(
              listenable: themeProvider,
              builder: (context, _) {
                return _buildSwitchTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Modo oscuro',
                  subtitle: 'Alterne la apariencia de la aplicación',
                  value: themeProvider.isDarkMode,
                  onChanged: (v) {
                    HapticFeedback.mediumImpact();
                    themeProvider.toggleTheme(v);
                  },
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.history_rounded,
              title: 'Historial de reservas',
              color: primaryBlue,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingHistoryScreen(isProvider: false),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            _buildSectionTitle('Soporte y ayuda', icon: Icons.support_agent_rounded),
            _buildOptionTile(
              icon: Icons.email_rounded,
              title: 'Correo de Soporte',
              subtitle: 'soporte@servizone.com',
              color: Colors.green,
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(const ClipboardData(text: 'soporte@servizone.com'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Correo copiado al portapapeles'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.phone_rounded,
              title: 'Teléfono principal',
              subtitle: '+57 (4) 444-5555',
              color: primaryBlue,
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(const ClipboardData(text: '+57 (4) 444-5555'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teléfono copiado al portapapeles'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.chat_rounded,
              title: 'WhatsApp',
              subtitle: '+57 300 123 4567',
              color: Colors.green,
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(const ClipboardData(text: '+57 300 123 4567'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Número copiado al portapapeles'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            _buildOptionTile(
              icon: Icons.business_center_rounded,
              title: 'Ser Proveedor',
              subtitle: 'Ofrece tus servicios en la plataforma',
              color: primaryBlue,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, AppRoutes.providerRequest);
              },
            ),
            _buildOptionTile(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              subtitle: 'Salir de tu cuenta de forma segura',
              color: Colors.red,
              onTap: () {
                HapticFeedback.heavyImpact();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.onLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: primaryBlue),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: mediumGray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: mediumGray, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}
