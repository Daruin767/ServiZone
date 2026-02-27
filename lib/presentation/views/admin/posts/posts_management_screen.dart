import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/post_model.dart';

class PostsManagementScreen extends StatefulWidget {
  const PostsManagementScreen({super.key});

  @override
  State<PostsManagementScreen> createState() => _PostsManagementScreenState();
}

class _PostsManagementScreenState extends State<PostsManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Post> posts = [
    Post(
      id: '001',
      title: 'Nueva promoción de servicios de limpieza',
      content: 'Disfruta de un 20% de descuento en todos nuestros servicios de limpieza profesional durante este mes...',
      category: 'Promociones',
      author: 'Admin Principal',
      publishDate: DateTime.now().subtract(const Duration(days: 2)),
      isPublished: true,
      isFeatured: true,
      views: 1247,
      likes: 89,
      imageUrl: 'https://example.com/cleaning.jpg',
    ),
    Post(
      id: '002',
      title: 'Nuevos proveedores de electricidad',
      content: 'Nos complace anunciar que hemos incorporado nuevos electricistas certificados a nuestra plataforma...',
      category: 'Anuncios',
      author: 'María García',
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      isPublished: true,
      isFeatured: false,
      views: 856,
      likes: 34,
      imageUrl: 'https://example.com/electrician.jpg',
    ),
    Post(
      id: '003',
      title: 'Consejos para el mantenimiento del hogar',
      content: 'Te compartimos los mejores consejos para mantener tu hogar en perfectas condiciones durante todo el año...',
      category: 'Consejos',
      author: 'Carlos Mendoza',
      publishDate: DateTime.now().subtract(const Duration(days: 8)),
      isPublished: false,
      isFeatured: false,
      views: 423,
      likes: 67,
      imageUrl: 'https://example.com/maintenance.jpg',
    ),
    Post(
      id: '004',
      title: 'ServiZone celebra 2 años de servicio',
      content: 'Estamos emocionados de celebrar nuestro segundo aniversario conectando usuarios con los mejores proveedores...',
      category: 'Noticias',
      author: 'Admin Principal',
      publishDate: DateTime.now().subtract(const Duration(days: 12)),
      isPublished: true,
      isFeatured: true,
      views: 2156,
      likes: 245,
      imageUrl: 'https://example.com/anniversary.jpg',
    ),
  ];

  List<Post> filteredPosts = [];
  String searchQuery = '';
  String selectedCategory = 'Todas';
  String selectedStatus = 'Todas';
  bool isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPosts = List.from(posts);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPosts() {
    setState(() {
      filteredPosts = posts.where((post) {
        bool matchesSearch = searchQuery.isEmpty ||
            post.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            post.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
            post.author.toLowerCase().contains(searchQuery.toLowerCase());
        bool matchesCategory = selectedCategory == 'Todas' || post.category == selectedCategory;
        bool matchesStatus = selectedStatus == 'Todas' ||
            (selectedStatus == 'Publicadas' && post.isPublished) ||
            (selectedStatus == 'Borradores' && !post.isPublished) ||
            (selectedStatus == 'Destacadas' && post.isFeatured);
        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedPostCategory = 'Promociones';
    bool isPostPublished = false;
    bool isPostFeatured = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.add_rounded, color: primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    const Text('Nueva Publicación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Título de la publicación',
                            prefixIcon: Icon(Icons.title_rounded, color: primaryBlue),
                            filled: true,
                            fillColor: lightGray,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: selectedPostCategory,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: Icon(Icons.category_rounded, color: primaryBlue),
                            filled: true,
                            fillColor: lightGray,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                          ),
                          items: ['Promociones', 'Anuncios', 'Consejos', 'Noticias']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setDialogState(() => selectedPostCategory = v!),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: contentController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            labelText: 'Contenido',
                            prefixIcon: Padding(padding: const EdgeInsets.only(bottom: 120), child: Icon(Icons.description_rounded, color: primaryBlue)),
                            filled: true,
                            fillColor: lightGray,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Configuración', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkGray)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Publicar inmediatamente', style: TextStyle(fontSize: 15, color: darkGray)),
                                  Switch(value: isPostPublished, onChanged: (v) => setDialogState(() => isPostPublished = v), activeColor: primaryBlue),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Destacar publicación', style: TextStyle(fontSize: 15, color: darkGray)),
                                  Switch(value: isPostFeatured, onChanged: (v) => setDialogState(() => isPostFeatured = v), activeColor: Colors.orange),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: mediumGray), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                            final newPost = Post(
                              id: '${posts.length + 1}'.padLeft(3, '0'),
                              title: titleController.text,
                              content: contentController.text,
                              category: selectedPostCategory,
                              author: 'Admin Principal',
                              publishDate: DateTime.now(),
                              isPublished: isPostPublished,
                              isFeatured: isPostFeatured,
                              views: 0,
                              likes: 0,
                              imageUrl: 'https://example.com/default.jpg',
                            );
                            setState(() {
                              posts.insert(0, newPost);
                              _filterPosts();
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isPostPublished ? 'Publicación publicada' : 'Guardada como borrador'), backgroundColor: primaryBlue),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text(isPostPublished ? 'Publicar' : 'Guardar borrador'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilters() {
    final categories = ['Todas', 'Promociones', 'Anuncios', 'Consejos', 'Noticias'];
    final statuses = ['Todas', 'Publicadas', 'Borradores', 'Destacadas'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
              const SizedBox(height: 24),
              const Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkGray)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: categories.map((c) => FilterChip(
                  label: Text(c),
                  selected: selectedCategory == c,
                  onSelected: (selected) {
                    setBottomSheetState(() => selectedCategory = c);
                    setState(() => selectedCategory = c);
                    _filterPosts();
                  },
                  selectedColor: primaryBlue.withOpacity(0.2),
                  checkmarkColor: primaryBlue,
                )).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkGray)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: statuses.map((s) => FilterChip(
                  label: Text(s),
                  selected: selectedStatus == s,
                  onSelected: (selected) {
                    setBottomSheetState(() => selectedStatus = s);
                    setState(() => selectedStatus = s);
                    _filterPosts();
                  },
                  selectedColor: primaryBlue.withOpacity(0.2),
                  checkmarkColor: primaryBlue,
                )).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () { setState(() { selectedCategory = 'Todas'; selectedStatus = 'Todas'; }); _filterPosts(); Navigator.pop(context); }, child: const Text('Limpiar'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryBlue), child: const Text('Aplicar'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editPost(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando: ${post.title}'), backgroundColor: primaryBlue, behavior: SnackBarBehavior.floating),
    );
  }

  void _deletePost(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar publicación?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar "${post.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                posts.removeWhere((p) => p.id == post.id);
                _filterPosts();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Publicación eliminada'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post, int index) {
    String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: cardShadow, blurRadius: 10)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _editPost(post),
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
                              decoration: BoxDecoration(color: _getCategoryColor(post.category).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(_getCategoryIcon(post.category), color: _getCategoryColor(post.category)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGray), maxLines: 2)),
                                      if (post.isFeatured)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                                              SizedBox(width: 4),
                                              Text('Destacada', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(post.category, style: TextStyle(fontSize: 12, color: _getCategoryColor(post.category), fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _editPost(post);
                                else if (value == 'delete') _deletePost(post);
                                else if (value == 'toggle_status') setState(() { post.isPublished = !post.isPublished; _filterPosts(); });
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded), SizedBox(width: 8), Text('Editar')])),
                                PopupMenuItem(value: 'toggle_status', child: Row(children: [Icon(post.isPublished ? Icons.visibility_off_rounded : Icons.visibility_rounded), SizedBox(width: 8), Text(post.isPublished ? 'Despublicar' : 'Publicar')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                              ],
                              child: Container(padding: const EdgeInsets.all(8), child: Icon(Icons.more_vert_rounded, color: mediumGray)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(post.content, style: const TextStyle(fontSize: 14, color: mediumGray, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.person_rounded, size: 16, color: mediumGray),
                            const SizedBox(width: 6),
                            Text(post.author, style: const TextStyle(fontSize: 12, color: mediumGray)),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today_rounded, size: 16, color: mediumGray),
                            const SizedBox(width: 6),
                            Text(formatDate(post.publishDate), style: const TextStyle(fontSize: 12, color: mediumGray)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: post.isPublished ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(post.isPublished ? 'Publicado' : 'Borrador', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: post.isPublished ? Colors.green : Colors.orange)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility_rounded, size: 14, color: primaryBlue),
                                  const SizedBox(width: 4),
                                  Text('${post.views}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.favorite_rounded, size: 14, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text('${post.likes}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                                ],
                              ),
                            ),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Promociones': return const Color(0xFF4CAF50);
      case 'Anuncios': return const Color(0xFF2196F3);
      case 'Consejos': return const Color(0xFFFF9800);
      case 'Noticias': return const Color(0xFF9C27B0);
      default: return primaryBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Promociones': return Icons.local_offer_rounded;
      case 'Anuncios': return Icons.campaign_rounded;
      case 'Consejos': return Icons.lightbulb_rounded;
      case 'Noticias': return Icons.newspaper_rounded;
      default: return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: Column(
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
                        child: Icon(Icons.article_rounded, color: primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      const Text('Gestión de Publicaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('${filteredPosts.length} publicaciones', style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            searchQuery = value;
                            _filterPosts();
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar publicaciones...',
                            prefixIcon: Icon(Icons.search_rounded, color: mediumGray),
                            suffixIcon: searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear_rounded, color: mediumGray), onPressed: () { _searchController.clear(); searchQuery = ''; _filterPosts(); }) : null,
                            filled: true,
                            fillColor: lightGray,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          onPressed: _showFilters,
                          style: IconButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredPosts.isEmpty
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
                            child: Icon(searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.article_rounded, size: 40, color: mediumGray),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            searchQuery.isNotEmpty ? 'No se encontraron publicaciones' : 'No hay publicaciones',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: mediumGray),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) => _buildPostCard(filteredPosts[index], index),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Publicación'),
      ),
    );
  }
}