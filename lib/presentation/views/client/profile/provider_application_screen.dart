import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';

class ProviderApplicationScreen extends StatefulWidget {
  const ProviderApplicationScreen({super.key});

  @override
  State<ProviderApplicationScreen> createState() => _ProviderApplicationScreenState();
}

class _ProviderApplicationScreenState extends State<ProviderApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descripcionController = TextEditingController();
  final _aniosController = TextEditingController();

  String? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  String? _tipoServicioSeleccionado;

  final List<String> _categorias = ['Hogar', 'Electricidad', 'Jardinería', 'Limpieza'];
  final Map<String, List<String>> _subcategorias = {
    'Hogar': ['Plomería', 'Carpintería', 'Pintura'],
    'Electricidad': ['Instalaciones', 'Reparaciones', 'Mantenimiento'],
    'Jardinería': ['Corte de césped', 'Poda', 'Diseño de jardines'],
    'Limpieza': ['Limpieza general', 'Limpieza profunda', 'Limpieza de alfombras'],
  };
  final Map<String, List<String>> _tiposServicio = {
    'Plomería': ['Mantenimiento', 'Instalación', 'Emergencia'],
    'Carpintería': ['Muebles a medida', 'Reparaciones', 'Instalación de puertas'],
    'Pintura': ['Interior', 'Exterior', 'Decorativa'],
    'Instalaciones': ['Eléctricas', 'Sanitarias', 'Gas'],
    'Reparaciones': ['Electrodomésticos', 'Cableado', 'Tableros'],
    'Mantenimiento': ['Preventivo', 'Correctivo'],
    'Corte de césped': ['Residencial', 'Comercial'],
    'Poda': ['Árboles', 'Arbustos'],
    'Diseño de jardines': ['Planos', 'Ejecución'],
    'Limpieza general': ['Casas', 'Oficinas'],
    'Limpieza profunda': ['Post-obra', 'Mudanza'],
    'Limpieza de alfombras': ['Hogar', 'Empresas'],
  };

  bool _archivoCargado = false;
  String _nombreArchivo = '';

  @override
  void dispose() {
    _descripcionController.dispose();
    _aniosController.dispose();
    super.dispose();
  }

  void _simularCargaArchivo() {
    setState(() {
      _archivoCargado = true;
      _nombreArchivo = 'certificado_${DateTime.now().millisecondsSinceEpoch}.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Archivo cargado correctamente (simulación)'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _enviarSolicitud() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Solicitud enviada'),
          content: const Text(
            'Tu solicitud para convertirte en proveedor ha sido recibida. El administrador la revisará y te notificará.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ServiZone',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5AA8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Volver',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        'Formulario de solicitud para proveedor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Certificaciones',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: _simularCargaArchivo,
                        child: Container(
                          width: double.infinity,
                          height: 110,
                          decoration: BoxDecoration(
                            color: lightGray,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _archivoCargado ? Icons.check_circle : Icons.cloud_upload,
                                size: 40,
                                color: _archivoCargado ? Colors.green : mediumGray,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _archivoCargado ? _nombreArchivo : 'Cargar archivos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _archivoCargado ? Colors.green : mediumGray,
                                  fontWeight: _archivoCargado ? FontWeight.w500 : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Descripción profesional',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: _descripcionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'Describe tu experiencia, especialidades, etc.',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo requerido';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Años de experiencia',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: lightGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _aniosController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                hintText: 'Ej: 5',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo requerido';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Número inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _enviarSolicitud,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5AA8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Aplicar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
