import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _listingsRef => _firestore.collection('listings');

  Stream<List<Listing>> getAllListings() {
    return _listingsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  /// Sorted client-side to avoid requiring a Firestore composite index.
  Stream<List<Listing>> getUserListings(String uid) {
    return _listingsRef
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final listings =
          snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
      listings.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return listings;
    });
  }

  Future<void> createListing(Listing listing) async {
    await _listingsRef.add({
      ...listing.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateListing(String id, Listing listing) async {
    await _listingsRef.doc(id).update(listing.toMap());
  }

  Future<void> deleteListing(String id) async {
    await _listingsRef.doc(id).delete();
  }
}
