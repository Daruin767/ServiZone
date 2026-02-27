import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/user_model.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;

  List<User> users = [
    User(
      id: '1',
      name: 'Ana García Rodríguez',
      phone: '3001234567',
      address: 'Calle 123 #45-67, Medellín',
      age: 25,
      status1: true,
      status2: false,
      status3: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    User(
      id: '2',
      name: 'Carlos Mendoza López',
      phone: '3019876543',
      address: 'Carrera 45 #12-34, Bogotá',
      age: 30,
      status1: false,
      status2: true,
      status3: false,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    User(
      id: '3',
      name: 'María Fernández Castro',
      phone: '3025551212',
      address: 'Av. Siempre Viva 742, Cali',
      age: 28,
      status1: true,
      status2: true,
      status3: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<User> filteredUsers = [];
  String searchQuery = '';
  bool _showLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _searchController = TextEditingController();
  bool _status1 = false;
  bool _status2 = false;
  bool _status3 = false;
  User? _editingUser;

  @override
  void initState() {
    super.initState();
    filteredUsers = List.from(users);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredUsers = List.from(users);
      } else {
        filteredUsers = users.where((user) {
          return user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.phone.contains(query) ||
              user.address.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _editUser(User user) {
    setState(() {
      _editingUser = user;
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.address;
      _ageController.text = user.age.toString();
      _status1 = user.status1;
      _status2 = user.status2;
      _status3 = user.status3;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildEditUserDialog(),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar usuario?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar a ${user.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _performDeleteUser(User user) {
    setState(() => _showLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        users.removeWhere((u) => u.id == user.id);
        _filterUsers(searchQuery);
        _showLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado correctamente'), backgroundColor: Colors.red),
      );
    });
  }

  void _saveUserChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() => _showLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (_editingUser != null) {
            _editingUser!.name = _nameController.text;
            _editingUser!.phone = _phoneController.text;
            _editingUser!.address = _addressController.text;
            _editingUser!.age = int.tryParse(_ageController.text) ?? _editingUser!.age;
            _editingUser!.status1 = _status1;
            _editingUser!.status2 = _status2;
            _editingUser!.status3 = _status3;
          }
          _filterUsers(searchQuery);
          _showLoading = false;
          _editingUser = null;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado correctamente'), backgroundColor: Colors.green),
        );
      });
    }
  }

  Widget _buildEditUserDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.edit_rounded, color: primaryBlue),
                            ),
                            const SizedBox(width: 16),
                            const Text('Editar Usuario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkGray)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildDialogTextField(controller: _nameController, label: 'Nombre completo', icon: Icons.person_rounded),
                                const SizedBox(height: 20),
                                _buildDialogTextField(controller: _phoneController, label: 'Teléfono', icon: Icons.phone_rounded, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                                const SizedBox(height: 20),
                                _buildDialogTextField(controller: _addressController, label: 'Dirección', icon: Icons.location_on_rounded, maxLines: 2),
                                const SizedBox(height: 20),
                                _buildDialogTextField(controller: _ageController, label: 'Edad', icon: Icons.cake_rounded, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Estados del Usuario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkGray)),
                                      const SizedBox(height: 16),
                                      _buildStatusSwitch('Activo', _status1, (v) => setDialogState(() => _status1 = v), Colors.green),
                                      _buildStatusSwitch('Verificado', _status2, (v) => setDialogState(() => _status2 = v), primaryBlue),
                                      _buildStatusSwitch('Premium', _status3, (v) => setDialogState(() => _status3 = v), Colors.orange),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                            const SizedBox(width: 12),
                            ElevatedButton(onPressed: _saveUserChanges, child: const Text('Guardar')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
      ),
    );
  }

  Widget _buildStatusSwitch(String label, bool value, ValueChanged<bool> onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: darkGray)),
          Switch(value: value, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: cardShadow, blurRadius: 10)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _editUser(user),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [primaryBlue, lightBlue]),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10)],
                              ),
                              child: Center(
                                child: Text(
                                  user.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray)),
                                  const SizedBox(height: 4),
                                  Text('ID: ${user.id}', style: TextStyle(fontSize: 12, color: mediumGray)),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _editUser(user);
                                else if (value == 'delete') _deleteUser(user);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded), SizedBox(width: 8), Text('Editar')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                              ],
                              child: Container(padding: const EdgeInsets.all(8), child: Icon(Icons.more_vert_rounded, color: mediumGray)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.phone_rounded, size: 16, color: mediumGray),
                            const SizedBox(width: 8),
                            Text(user.phone, style: const TextStyle(fontSize: 14, color: mediumGray)),
                            const SizedBox(width: 20),
                            Icon(Icons.cake_rounded, size: 16, color: mediumGray),
                            const SizedBox(width: 8),
                            Text('${user.age} años', style: const TextStyle(fontSize: 14, color: mediumGray)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 16, color: mediumGray),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.address, style: const TextStyle(fontSize: 14, color: mediumGray), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatusChip('Activo', user.status1, Colors.green),
                            const SizedBox(width: 8),
                            _buildStatusChip('Verificado', user.status2, primaryBlue),
                            const SizedBox(width: 8),
                            _buildStatusChip('Premium', user.status3, Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : mediumGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? color.withOpacity(0.3) : mediumGray.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? color : mediumGray),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.group_rounded, color: primaryBlue),
                          ),
                          const SizedBox(width: 16),
                          const Text('Gestión de Usuarios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('${filteredUsers.length} usuarios', style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        onChanged: _filterUsers,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, teléfono o dirección...',
                          prefixIcon: Icon(Icons.search_rounded, color: mediumGray),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(icon: Icon(Icons.clear_rounded, color: mediumGray), onPressed: () { _searchController.clear(); _filterUsers(''); })
                              : null,
                          filled: true,
                          fillColor: lightGray,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredUsers.isEmpty
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(color: mediumGray.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.group_rounded, size: 40, color: mediumGray),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                searchQuery.isNotEmpty ? 'No se encontraron usuarios' : 'No hay usuarios registrados',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: mediumGray),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) => _buildUserCard(filteredUsers[index], index),
                      ),
              ),
            ],
          ),
          if (_showLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}