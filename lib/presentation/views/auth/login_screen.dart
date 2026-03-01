import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/data/providers/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool _isPasswordVisible = false;
  bool _showLoadingScreen = false;
  bool _showSuccessScreen = false;
  bool _showErrorScreen = false;
  String _errorMessage = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const String _baseUrl = 'http://10.1.117.214:7000';
  static const String _apiEndpoint = '/api/Auth/login';
  String get _apiUrl => '$_baseUrl$_apiEndpoint';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _validarCampos() {
    if (correoController.text.isEmpty || passwordController.text.isEmpty) {
      _showError('Todos los campos son obligatorios');
      return false;
    }
    if (!_isValidEmail(correoController.text)) {
      _showError('El correo no es válido');
      return false;
    }
    if (passwordController.text.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateForm() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() {
      _showLoadingScreen = true;
      _showErrorScreen = false;
      _showSuccessScreen = false;
    });
    _login();
  }

  Future<void> _login() async {
    if (!_validarCampos()) {
      setState(() => _showLoadingScreen = false);
      return;
    }
    setState(() => loading = true);

    try {
      final url = Uri.parse(_apiUrl);
      final body = {
        "Correo": correoController.text.trim(),
        "Password": passwordController.text.trim(),
      };
      final response = await http
          .post(url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String? token = responseData['token']?.toString();
          final Map<String, dynamic>? usuarioObj = responseData['usuario'] as Map<String, dynamic>?;
          final String? correo = usuarioObj?['correo'] ?? usuarioObj?['email'];
          final String? nombre = usuarioObj?['nombre'] ?? usuarioObj?['name'];

          if (token != null && token.isNotEmpty) {
            await _saveUserData(token, correo, nombre);
            setState(() {
              _showLoadingScreen = false;
              _showSuccessScreen = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
            });
          } else {
            _showError('Error: No se recibió token de autenticación');
          }
        } catch (jsonError) {
          _showError('Error procesando respuesta del servidor');
        }
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          String message = errorData['message'] ?? 'Credenciales incorrectas';
          _showError(message);
        } catch (_) {
          _showError('Error del servidor (${response.statusCode})');
        }
      }
    } on SocketException {
      _showError('Error de conexión. Verifica tu red.');
    } on Exception {
      _showError('Error inesperado');
    } finally {
      setState(() {
        loading = false;
        _showLoadingScreen = false;
      });
    }
  }

  Future<void> _saveUserData(String token, String? correo, String? nombre) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      if (correo != null) await prefs.setString('user_email', correo);
      if (nombre != null) await prefs.setString('user_name', nombre);
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      print('Error guardando datos: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _showErrorScreen = true;
      _errorMessage = message;
      _showLoadingScreen = false;
      _showSuccessScreen = false;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showErrorScreen = false);
    });
  }

  Widget _buildLoadingScreen() {
    return AnimatedOpacity(
      opacity: _showLoadingScreen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: _showLoadingScreen
          ? Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Validando credenciales',
                        style: TextStyle(
                          color: darkGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Iniciando sesión...',
                        style: TextStyle(
                          color: mediumGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildSuccessScreen() {
    return AnimatedOpacity(
      opacity: _showSuccessScreen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: _showSuccessScreen
          ? Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '¡Inicio Exitoso!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bienvenido a ServiZone',
                        style: TextStyle(
                          fontSize: 14,
                          color: mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildErrorScreen() {
    return AnimatedOpacity(
      opacity: _showErrorScreen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: _showErrorScreen
          ? Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Error de autenticación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: darkGray,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: mediumGray,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: TextStyle(color: mediumGray, fontSize: 14),
        hintStyle: TextStyle(color: mediumGray.withOpacity(0.7), fontSize: 14),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo ServiZone mejorado
                        Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Servi",
                                      style: TextStyle(color: primaryBlue),
                                    ),
                                    TextSpan(
                                      text: "Zone",
                                      style: TextStyle(color: darkGray),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tu plataforma de servicios',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: mediumGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Formulario principal
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: darkGray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Accede a tu cuenta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: mediumGray,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Campo de correo
                                _buildTextField(
                                  controller: correoController,
                                  label: "Correo electrónico",
                                  hint: "ejemplo@correo.com",
                                  icon: Icons.email_rounded,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu correo';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Campo de contraseña
                                _buildTextField(
                                  controller: passwordController,
                                  label: "Contraseña",
                                  hint: "Ingresa tu contraseña",
                                  icon: Icons.lock_rounded,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu contraseña';
                                    }
                                    if (value.length < 6) {
                                      return 'La contraseña debe tener al menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 32),

                                // Botón principal
                                Container(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: loading ? null : _validateForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      shadowColor: primaryBlue.withOpacity(0.3),
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            "Iniciar Sesión",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),

                                // ----- BOTONES DE ACCESO DIRECTO (SOLO PRUEBA) -----
                                const SizedBox(height: 24),
                                const Text(
                                  'Acceso directo (modo prueba)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: darkGray,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text('Admin'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pushNamed(context, AppRoutes.clientHome),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text('Cliente'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pushNamed(context, AppRoutes.providerHome),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text('Proveedor'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pushNamed(context, AppRoutes.guestHome),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text('Invitado'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // ------------------------------------------------

                                // Divisor
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'O continúa con',
                                        style: TextStyle(
                                          color: mediumGray,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Botones sociales
                                _buildSocialButton(
                                  text: "Continuar con Google",
                                  icon: Icons.g_mobiledata_rounded,
                                  iconColor: Colors.red,
                                  onPressed: () {},
                                ),

                                _buildSocialButton(
                                  text: "Continuar con Facebook",
                                  icon: Icons.facebook_rounded,
                                  iconColor: Colors.blue[800]!,
                                  onPressed: () {},
                                ),

                                const SizedBox(height: 24),

                                // Botón registrarse
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, AppRoutes.register);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: '¿No tienes cuenta? ',
                                        style: TextStyle(
                                          color: mediumGray,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Regístrate',
                                            style: TextStyle(
                                              color: primaryBlue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Términos y condiciones
                                Text(
                                  "Al continuar, aceptas nuestros Términos de servicio y Política de privacidad",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mediumGray,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Pantallas de estado
          _buildLoadingScreen(),
          _buildSuccessScreen(),
          _buildErrorScreen(),
        ],
      ),
    );
  }
}