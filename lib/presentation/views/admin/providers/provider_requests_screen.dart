import 'package:flutter/material.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/booking_model.dart';

class ProviderRequest {
  final String id;
  final String name;
  final String email;
  final DateTime requestDate;

  ProviderRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.requestDate,
  });
}

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  final List<ProviderRequest> _requests = [
    ProviderRequest(
      id: '1',
      name: 'Andrés Felipe Restrepo',
      email: 'andres.restrepo@email.com',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProviderRequest(
      id: '2',
      name: 'Laura Sofía Gómez',
      email: 'laura.gomez@email.com',
      requestDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ProviderRequest(
      id: '3',
      name: 'Miguel Ángel Torres',
      email: 'miguel.torres@email.com',
      requestDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<ProviderRequest> _history = [];

  void _handleRequest(String id, bool accept) {
    setState(() {
      final request = _requests.firstWhere((r) => r.id == id);
      _requests.removeWhere((r) => r.id == id);
      _history.add(request);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(accept ? 'Solicitud aceptada' : 'Solicitud rechazada'),
        backgroundColor: accept ? successGreen : errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Solicitudes de Proveedores',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textGray,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () {
              // TODO: Implementar filtros de solicitudes
            },
          ),
        ],
      ),
      body: _requests.isEmpty
          ? const Center(
              child: Text(
                'No hay solicitudes pendientes',
                style: TextStyle(color: textGray, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return _buildRequestCard(request);
              },
            ),
    );
  }

  Widget _buildRequestCard(ProviderRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: purple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.person_outline_rounded, color: purple, size: 28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: textStyleSubtitleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.email,
                      style: textStyleBodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solicitado el: ${request.requestDate.day}/${request.requestDate.month}/${request.requestDate.year}',
                style: textStyleHelperSmall,
              ),
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    color: errorRed,
                    onTap: () => _handleRequest(request.id, false),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.check_rounded,
                    color: successGreen,
                    onTap: () => _handleRequest(request.id, true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool accept) {
    final color = accept ? successGreen : errorRed;
    final label = accept ? 'ACEPTADA' : 'RECHAZADA';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
