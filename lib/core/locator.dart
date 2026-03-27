import 'package:get_it/get_it.dart';
import 'package:servizone_app/core/services/provider_booking_service.dart';
import 'package:servizone_app/core/network/api_client.dart';
import 'package:servizone_app/data/providers/auth_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
  locator.registerLazySingleton<AuthService>(() => AuthService(locator<ApiClient>()));
  locator.registerLazySingleton<ProviderBookingService>(() => ProviderBookingService());
}
