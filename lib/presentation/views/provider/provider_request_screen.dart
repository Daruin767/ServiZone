import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';

class ProviderRequestScreen extends StatefulWidget {
  const ProviderRequestScreen({super.key});

  @override
  State<ProviderRequestScreen> createState() => _ProviderRequestScreenState();
}

class _ProviderRequestScreenState extends State<ProviderRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _experienceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validación adicional para asegurar que hay al menos un archivo (simulado)
      setState(() => _isUploading = true);
      
      // Simular proceso de validación y envío
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isUploading = false);
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
      backgroundColor: Colors.white,
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
                        backgroundColor: primaryDarkBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Volver',
                        style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Título principal
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
                
                // Certificaciones
                _buildLabel('Certificaciones'),
                const SizedBox(height: 8),
                _buildUploadArea(),
                
                const SizedBox(height: 24),
                
                // Descripción profesional
                _buildLabel('Descripción profesional'),
                const SizedBox(height: 8),
                _buildTextArea(),
                
                const SizedBox(height: 24),
                
                // Años de experiencia
                _buildLabel('Años de experiencia'),
                const SizedBox(height: 8),
                _buildNumericField(),
                
                const SizedBox(height: 48),
                
                // Botón Aplicar
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primaryBlue.withValues(alpha: 0.3),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Aplicar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
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
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textGray,
      ),
    );
  }

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: backgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGray, style: BorderStyle.solid),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // Simular carga de archivos
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.cloud_upload_outlined, size: 32, color: primaryBlue),
              SizedBox(height: 8),
              Text(
                'Cargar archivos',
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

  Widget _buildTextArea() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Cuéntanos sobre tu experiencia y habilidades...',
        hintStyle: TextStyle(color: textGray.withValues(alpha: 0.5), fontSize: 14),
        fillColor: backgroundGray,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Por favor ingresa una descripción' : null,
    );
  }

  Widget _buildNumericField() {
    return TextFormField(
      controller: _experienceController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: 'Ej. 5',
        hintStyle: TextStyle(color: textGray.withValues(alpha: 0.5), fontSize: 14),
        fillColor: backgroundGray,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
    );
  }
}
