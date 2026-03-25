import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';

class ProviderRequestScreen extends StatefulWidget {
  const ProviderRequestScreen({super.key});

  @override
  State<ProviderRequestScreen> createState() => _ProviderRequestScreenState();
}

class _ProviderRequestScreenState extends State<ProviderRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _lastNameController.text = prefs.getString('user_lastname') ?? '';
      _emailController.text = prefs.getString('user_email') ?? '';
      _phoneController.text = prefs.getString('user_phone') ?? '';
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simular envío al servidor
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitud enviada con éxito. Un administrador revisará tu perfil.'),
              backgroundColor: successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      });
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'ServiZone',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Formulario de solicitud para proveedor',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 32),

                // Nombre
                _buildLabel('Nombre'),
                const SizedBox(height: 8),
                _buildTextField(_nameController, hint: 'Tu nombre'),
                const SizedBox(height: 16),

                // Apellido
                _buildLabel('Apellido'),
                const SizedBox(height: 8),
                _buildTextField(_lastNameController, hint: 'Tu apellido'),
                const SizedBox(height: 16),

                // Correo
                _buildLabel('Correo electrónico'),
                const SizedBox(height: 8),
                _buildTextField(_emailController,
                    hint: 'ejemplo@correo.com',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                // Teléfono
                _buildLabel('Número de celular'),
                const SizedBox(height: 8),
                _buildTextField(_phoneController,
                    hint: '+57 300 123 4567', keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                // Descripción
                _buildLabel('Descripción profesional'),
                const SizedBox(height: 8),
                _buildTextArea(),
                const SizedBox(height: 16),

                // Años de experiencia
                _buildLabel('Años de experiencia'),
                const SizedBox(height: 8),
                _buildNumericField(),
                const SizedBox(height: 24),

                // Certificaciones (opcional)
                _buildLabel('Certificaciones (opcional)'),
                const SizedBox(height: 8),
                _buildUploadArea(),
                const SizedBox(height: 48),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: textGray),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Enviar solicitud'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textGray,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {String hint = '', TextInputType keyboardType = TextInputType.text}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: darkGray,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: textGray.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: darkGray,
        ),
        decoration: InputDecoration(
          hintText: 'Cuéntanos sobre tu experiencia y habilidades...',
          hintStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: textGray.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildNumericField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: _experienceController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: darkGray,
        ),
        decoration: InputDecoration(
          hintText: 'Ej. 5',
          hintStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: textGray.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidad de carga de archivos simulada'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 32, color: primaryBlue),
              SizedBox(height: 8),
              Text(
                'Cargar certificaciones (PDF, imágenes)',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}