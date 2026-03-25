import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/booking_model.dart';
import 'package:servizone_app/presentation/widgets/shared/status_badge.dart';
import 'package:servizone_app/presentation/widgets/shared/booking_detail_sheet.dart';

class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  String _priceSort = 'none'; // 'asc', 'desc', 'none'
  String _dateSort = 'desc'; // 'asc', 'desc'
  final List<String> _selectedServiceTypes = [];

  // Datos de ejemplo para las solicitudes (solo pendientes)
  final List<BookingModel> _allRequests = [
    BookingModel(
      id: 'req1',
      clientId: 'C1',
      providerId: 'P1',
      clientName: 'Juan Pérez',
      serviceType: 'Plomería',
      serviceName: 'Fuga de agua',
      date: DateTime.now().add(const Duration(days: 1)),
      address: 'Calle 123 # 45-67',
      price: 45000,
      status: BookingStatus.pendiente,
      providerName: 'Carlos Electrics',
    ),
    BookingModel(
      id: 'req2',
      clientId: 'C1',
      providerId: 'P2',
      clientName: 'Juan Pérez',
      serviceType: 'Electricidad',
      serviceName: 'Cortocircuito',
      date: DateTime.now().add(const Duration(days: 2)),
      address: 'Calle 123 # 45-67',
      price: 60000,
      status: BookingStatus.pendiente,
      providerName: 'Electricistas Ya',
    ),
  ];

  List<String> get _availableServiceTypes {
    return _allRequests.map((e) => e.serviceType).toSet().toList();
  }

  List<BookingModel> get _filteredRequests {
    var list = _allRequests.where((req) {
      bool typeMatch = _selectedServiceTypes.isEmpty || _selectedServiceTypes.contains(req.serviceType);
      return typeMatch;
    }).toList();

    if (_priceSort == 'asc') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_priceSort == 'desc') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_dateSort == 'asc') {
      list.sort((a, b) => a.date.compareTo(b.date));
    } else {
      list.sort((a, b) => b.date.compareTo(a.date));
    }
    
    return list;
  }

  void _showNotification(String message, {bool isError = false}) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: isError ? errorRed : successGreen,
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
        title: const Text('Mis Solicitudes', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textGray,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              setState(() {
                if (value == 'price_asc') {
                  _priceSort = 'asc';
                  _dateSort = 'none';
                } else if (value == 'price_desc') {
                  _priceSort = 'desc';
                  _dateSort = 'none';
                } else if (value == 'date_asc') {
                  _dateSort = 'asc';
                  _priceSort = 'none';
                } else if (value == 'date_desc') {
                  _dateSort = 'desc';
                  _priceSort = 'none';
                } else if (value.startsWith('type_')) {
                  final type = value.substring(5);
                  if (_selectedServiceTypes.contains(type)) {
                    _selectedServiceTypes.remove(type);
                  } else {
                    _selectedServiceTypes.add(type);
                  }
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                child: Text('Filtrar por tipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              ..._availableServiceTypes.map((type) => PopupMenuItem(
                value: 'type_$type',
                child: Row(
                  children: [
                    Icon(
                      _selectedServiceTypes.contains(type) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(type),
                  ],
                ),
              )),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text('Ordenar por', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              PopupMenuItem(
                value: 'date_desc',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: _dateSort == 'desc' ? primaryBlue : textGray, size: 20),
                    const SizedBox(width: 12),
                    const Text('Fecha: más reciente'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price_asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: _priceSort == 'asc' ? primaryBlue : textGray, size: 20),
                    const SizedBox(width: 12),
                    const Text('Precio: menor a mayor'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price_desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, color: _priceSort == 'desc' ? primaryBlue : textGray, size: 20),
                    const SizedBox(width: 12),
                    const Text('Precio: mayor a menor'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _filteredRequests.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredRequests.length,
              itemBuilder: (context, index) => _buildRequestCard(_filteredRequests[index]),
            ),
    );
  }

  Widget _buildRequestCard(BookingModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 8)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => BookingDetailSheet(booking: request),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        request.serviceName,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: darkGray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const StatusBadge(status: BookingStatus.pendiente),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Proveedor: ${request.providerName ?? 'Buscando...'}',
                  style: const TextStyle(color: textGray, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: textGray),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy - hh:mm a').format(request.date),
                      style: const TextStyle(color: textGray, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${NumberFormat('#,###').format(request.price)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        // Lógica de cancelación de solicitud
                        _showNotification('Solicitud cancelada');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: errorRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar', style: TextStyle(color: errorRed, fontSize: 12)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_rounded, size: 80, color: primaryBlue.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('No tienes solicitudes pendientes', style: TextStyle(color: textGray, fontSize: 16, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
