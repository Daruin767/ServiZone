import 'package:get_it/get_it.dart';
import 'package:servizone_app/core/services/provider_booking_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ProviderBookingService>(() => ProviderBookingService());
}
