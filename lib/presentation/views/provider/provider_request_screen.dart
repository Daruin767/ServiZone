import 'package:flutter/material.dart';
import 'package:servizone_app/core/constants/app_constants.dart';

class ProviderRequestScreen extends StatefulWidget {
  const ProviderRequestScreen({super.key});

  @override
  State<ProviderRequestScreen> createState() => _ProviderRequestScreenState();
}

class _ProviderRequestScreenState extends State<ProviderRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = ['Hogar', 'Ciclismo', 'Cuidado Personal', 'Mascotas', 'Otros'];

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Solicitud Enviada', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          content: const Text('Tu solicitud para ser proveedor ha sido enviada. El administrador la revisará pronto.', style: TextStyle(fontFamily: 'Roboto')),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver al perfil
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Ser Proveedor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¡Únete como Socio!', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 12),
              Text(
                'Completa el formulario para ofrecer tus servicios en ServiZone.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: mediumGray),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre comercial o profesional', prefixIcon: Icon(Icons.business_rounded)),
                validator: (v) => v == null || v.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoría principal', prefixIcon: Icon(Icons.category_rounded)),
                items: _categories.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono de contacto', prefixIcon: Icon(Icons.phone_rounded)),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Breve descripción de tus servicios', prefixIcon: Icon(Icons.description_rounded)),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  child: const Text('Enviar Solicitud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
