import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/provider/provider_home_screen.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:servizone_app/core/routes/app_routes.dart'; 

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});

  @override
  State<ProviderEditProfileScreen> createState() => _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _userName = 'Usuario';
  bool _isLoading = false;
  int _currentIndex = 3; // Cuenta activa

  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = 'Error al actualizar';

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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    final random = DateTime.now().millisecondsSinceEpoch % 2;
    if (random == 0) {
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccess = false);
          Navigator.pop(context);
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _showError = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          Column(
            children: [
              // Header con avatar, nombre y botón Volver azul
              Container(
                height: 80,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(_userName),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '@$_userName',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    // Botón Volver azul
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00569D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(70, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Volver',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Editar información',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: darkGray,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Campo Correo
                          Text(
                            'Correo electrónico',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: darkGray,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ejemplo@correo.com',
                                hintStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color: mediumGray,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  _showErrorSnackBar('El correo es requerido');
                                  return '';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  _showErrorSnackBar('Correo inválido');
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Campo Teléfono
                          Text(
                            'Número personal',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: darkGray,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ej: 3001234567',
                                hintStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color: mediumGray,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  _showErrorSnackBar('El número es requerido');
                                  return '';
                                }
                                if (value.length < 10) {
                                  _showErrorSnackBar('El número debe tener al menos 10 dígitos');
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Botón Actualizar
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00569D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
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
                                      'Actualizar datos',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Barra de navegación inferior
              _buildBottomNavBar(),

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

          // Modales
          if (_showSuccess)
            _buildModal(
              icon: Icons.check_circle,
              color: Colors.green,
              message: 'Datos actualizados',
            ),
          if (_showError)
            _buildModal(
              icon: Icons.cancel,
              color: Colors.red,
              message: _errorMessage,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
              );
              break;
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sección de servicios en desarrollo'), behavior: SnackBarBehavior.floating),
              );
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sección de reservas en desarrollo'), behavior: SnackBarBehavior.floating),
              );
              break;
            case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderProfileScreen(
                  onLogout: _logout,
                ),
              ),
            );
            break;
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: mediumGray,
        selectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Cuenta'),
        ],
      ),
    );
  }

  Widget _buildModal({required IconData icon, required Color color, required String message}) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 70, color: color),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: darkGray,
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