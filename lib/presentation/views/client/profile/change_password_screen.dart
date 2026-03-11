import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _userName = 'Usuario';
  bool _isLoading = false;

  // Visibilidad de contraseñas
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Estados para modales
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = 'Algo salió mal';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    if (name != null && mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  // Validaciones
  bool _hasMinLength(String pwd) => pwd.length >= 8;
  bool _hasUppercase(String pwd) => pwd.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String pwd) => pwd.contains(RegExp(r'[a-z]'));
  bool _hasNumber(String pwd) => pwd.contains(RegExp(r'[0-9]'));
  bool _hasSpecial(String pwd) => pwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool _passwordsMatch(String pwd, String confirm) => pwd == confirm && confirm.isNotEmpty;

  Future<void> _changePassword() async {
    // Validar campos no vacíos
    if (_currentPasswordController.text.isEmpty) {
      _showSnackBar('Ingresa tu contraseña actual');
      return;
    }
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Ingresa una nueva contraseña');
      return;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _showSnackBar('Confirma tu nueva contraseña');
      return;
    }

    final newPwd = _newPasswordController.text;
    final confirmPwd = _confirmPasswordController.text;

    // Validar requisitos de la nueva contraseña
    if (!_hasMinLength(newPwd)) {
      _showSnackBar('La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (!_hasUppercase(newPwd)) {
      _showSnackBar('La contraseña debe contener al menos una letra mayúscula');
      return;
    }
    if (!_hasLowercase(newPwd)) {
      _showSnackBar('La contraseña debe contener al menos una letra minúscula');
      return;
    }
    if (!_hasNumber(newPwd)) {
      _showSnackBar('La contraseña debe contener al menos un número');
      return;
    }
    if (!_hasSpecial(newPwd)) {
      _showSnackBar('La contraseña debe contener al menos un carácter especial (!@#\$%^&*)');
      return;
    }
    if (!_passwordsMatch(newPwd, confirmPwd)) {
      _showSnackBar('Las contraseñas no coinciden');
      return;
    }

    // Simular cambio de contraseña
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    // Simular éxito/error aleatorio
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    setState(() => _isLoading = false);

    if (random == 0) {
      setState(() => _showSuccess = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccess = false);
          Navigator.pop(context);
        }
      });
    } else {
      setState(() {
        _showError = true;
        _errorMessage = 'Algo salió mal';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          Column(
            children: [
              // Status bar simulada
              Container(
                height: 44,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '9:41',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.signal_cellular_alt, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Icon(Icons.wifi, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Container(
                          width: 22,
                          height: 12,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.all(1.5),
                              child: ColoredBox(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Header azul con avatar, nombre y botón volver
              Container(
                height: 80,
                color: const Color(0xFF166AA3),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Avatar circular gris
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6D6D6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(_userName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nombre de usuario
                    Text(
                      '@$_userName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Botón Volver (texto)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Volver',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal (scroll)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título con icono de candado
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 22,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Cambiar contraseña',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222222),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Campo: Contraseña actual
                        const Text(
                          'Contraseña actual',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),

                        const SizedBox(height: 20),

                        // Campo: Contraseña nueva
                        const Text(
                          'Contraseña nueva',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          onToggle: () => setState(() => _obscureNew = !_obscureNew),
                        ),

                        const SizedBox(height: 20),

                        // Campo: Confirmar contraseña
                        const Text(
                          'Confirmar contraseña',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),

                        const SizedBox(height: 32),

                        // Botón Cambiar contraseña
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF145A8D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Cambiar contraseña',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40), // Espacio extra para el scroll
                      ],
                    ),
                  ),
                ),
              ),

              // Barra de navegación inferior (fija)
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.calendar_month, 'Reservas', false),
                    _buildNavItem(Icons.grid_view, 'Servicios', false),
                    _buildNavItem(Icons.person, 'Cuenta', true),
                  ],
                ),
              ),

              // Barra de gestos iOS
              Container(
                height: 20,
                alignment: Alignment.topCenter,
                child: Container(
                  width: 140,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),

          // Modal de éxito
          if (_showSuccess)
            _buildModal(
              icon: Icons.check_circle,
              color: const Color(0xFF59D63A),
              message: 'Contraseña actualizada',
            ),

          // Modal de error
          if (_showError)
            _buildModal(
              icon: Icons.cancel,
              color: const Color(0xFFFF1A1A),
              message: _errorMessage,
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFDCDCDC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF8A8A8A),
              size: 20,
            ),
            onPressed: onToggle,
          ),
          hintText: '********',
          hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF166AA3) : const Color(0xFF9A9A9A),
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF166AA3) : const Color(0xFF9A9A9A),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildModal({required IconData icon, required Color color, required String message}) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 50,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}