import 'package:flutter/material.dart';
import 'package:servizone_app/core/constants/app_constants.dart';

class CreateServiceBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onServiceCreated;

  const CreateServiceBottomSheet({super.key, required this.onServiceCreated});

  static void show(BuildContext context, {required Function(Map<String, dynamic>) onServiceCreated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => CreateServiceBottomSheet(onServiceCreated: onServiceCreated),
    );
  }

  @override
  State<CreateServiceBottomSheet> createState() => _CreateServiceBottomSheetState();
}

class _CreateServiceBottomSheetState extends State<CreateServiceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedType;
  bool _isActive = true;

  final List<String> _categoriesList = ['Hogar', 'Ciclismo', 'Cuidado Personal', 'Mascotas', 'Otros'];
  final Map<String, List<String>> _subcategoriesMap = {
    'Hogar': ['Plomería', 'Electricidad', 'Limpieza', 'Jardinería'],
    'Ciclismo': ['Mantenimiento', 'Reparación', 'Venta de Accesorios'],
    'Cuidado Personal': ['Barbería', 'Manicura', 'Maquillaje'],
    'Mascotas': ['Paseo', 'Entrenamiento', 'Baño'],
    'Otros': ['Varios'],
  };
  final List<String> _typesList = ['Mantenimiento', 'Instalación', 'Reparación', 'Consultoría', 'Otros'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crear Nuevo Servicio', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del servicio', prefixIcon: Icon(Icons.build_rounded)),
                validator: (v) => v == null || v.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción', prefixIcon: Icon(Icons.description_rounded)),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'La descripción es obligatoria' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category_rounded)),
                items: _categoriesList.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() {
                  _selectedCategory = v;
                  _selectedSubcategory = null;
                }),
                validator: (v) => v == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Subcategoría', prefixIcon: Icon(Icons.list_rounded)),
                items: (_subcategoriesMap[_selectedCategory] ?? <String>[])
                    .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                value: _selectedSubcategory,
                onChanged: (v) => setState(() => _selectedSubcategory = v),
                validator: (v) => v == null ? 'Selecciona una subcategoría' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo de servicio', prefixIcon: Icon(Icons.merge_type_rounded)),
                items: _typesList.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Estado del servicio (Activo)'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeColor: primaryBlue,
                activeTrackColor: primaryBlue.withAlpha(100),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withAlpha(100),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onServiceCreated({
                        'name': _nameController.text,
                        'price': 0, // Precio por defecto o añadir campo
                        'status': _isActive ? 'Activo' : 'Inactivo',
                        'category': _selectedCategory,
                        'subcategory': _selectedSubcategory,
                        'type': _selectedType,
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Servicio creado correctamente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: successGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Crear Servicio', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
