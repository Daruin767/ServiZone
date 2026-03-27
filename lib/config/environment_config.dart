import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static late String apiBaseUrl;
  static late String googleMapsApiKey;
  
  static Future<void> load() async {
    // En desarrollo (Android Emulator: 10.0.2.2, Web/Local: localhost)
    if (kIsWeb) {
      apiBaseUrl = 'http://localhost:5059/api';
    } else {
      apiBaseUrl = 'http://10.0.2.2:5059/api';
    }

    googleMapsApiKey = 'TU_API_KEY'; // Cambia esto cuando tengas la key
    
    // En producción se cargaría desde variables de entorno
    // pero por ahora usamos valores por defecto
  }
  
  // Para diferentes entornos
  static void loadDevelopment() {
    if (kIsWeb) {
      apiBaseUrl = 'http://localhost:5059/api';
    } else {
      apiBaseUrl = 'http://10.0.2.2:5059/api';
    }
    googleMapsApiKey = 'dev_key';
  }
  
  static void loadProduction() {
    apiBaseUrl = 'https://api.servizone.com/v1';
    googleMapsApiKey = 'prod_key';
  }
}


