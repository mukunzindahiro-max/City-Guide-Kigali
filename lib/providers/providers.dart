import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing.dart';
import '../services/auth_service.dart';
import '../services/listing_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final listingServiceProvider =
    Provider<ListingService>((ref) => ListingService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final allListingsProvider = StreamProvider<List<Listing>>((ref) {
  return ref.watch(listingServiceProvider).getAllListings();
});

final userListingsProvider = StreamProvider<List<Listing>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid ?? '';
  return ref.watch(listingServiceProvider).getUserListings(uid);
});
