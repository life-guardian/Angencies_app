import 'package:flutter_riverpod/flutter_riverpod.dart';

final agencyNameProvider = StateProvider<String>((ref) => "Loading...");

final eventsCountProvider = StateProvider<List<String>>((ref) => ['0', '0']);

final tokenProvider = StateProvider<String>((ref) => "");

final isRescueOperationOnGoingProvider = StateProvider<bool>((ref) => false);

final rescueOperationIdProvider = StateProvider<String?>((ref) {
  return null;
});
