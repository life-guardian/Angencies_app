import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceLocationProvider =
    StateProvider<List<double>>((ref) => [16.6619717, 74.20947]);

final accessLiveLocationProvider = StateProvider<bool>((ref) => false);


