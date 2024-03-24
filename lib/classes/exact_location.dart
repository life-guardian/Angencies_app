import 'package:geocoding/geocoding.dart';

class ExactLocation {
  // final double lat;
  // final double lng;

  // ExactLocation({required this.lat, required this.lng});

  Future<String> locality({required double lat, required double lng}) async {
    String? locality;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark placemark = placemarks[0];
      locality = placemark.locality;
    } catch (error) {
      // catched error while fetching exact location
    }
    return locality!;
  }
}
