import 'package:cloud_firestore/cloud_firestore.dart';


// Load, update, delete information 
class ItineraryService {
  final CollectionReference _itineraryCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<List<Map<String, dynamic>>> loadItineraryItems(String userId) async {
    try {
      final QuerySnapshot snapshot = await _itineraryCollection
          .doc(userId)
          .collection('Itineraries')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['itinerary.id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error loading itinerary items: $e');
      return [];
    }
  }

  Future<void> saveItinerary(String userId, Map<String, dynamic> itinerary) async {
    try {
      DocumentReference docRef = await _itineraryCollection
          .doc(userId)
          .collection('Itineraries')
         .add({
            'itinerary.title': itinerary['itinerary.title'],
            'itinerary.description': itinerary['itinerary.description'],
            'itinerary.startDate': itinerary['itinerary.startDate'],
            'itinerary.endDate': itinerary['itinerary.endDate'],
          });
      itinerary['itinerary.id'] = docRef.id;
    } catch (e) {
      print('Error saving itinerary to Firestore: $e');
    }
  }

  Future<void> updateItinerary(String userId, Map<String, dynamic> itinerary) async {
    String docId = itinerary['itinerary.id'];
    try {
      await _itineraryCollection
          .doc(userId)
          .collection('Itineraries')
          .doc(docId)
          .update({
            'itinerary.title': itinerary['itinerary.title'],
            'itinerary.description': itinerary['itinerary.description'],
            'itinerary.startDate': itinerary['itinerary.startDate'],
            'itinerary.endDate': itinerary['itinerary.endDate'],
          });
    } catch (e) {
      print('Error updating itinerary in Firestore: $e');
    }
  }

  Future<void> deleteItinerary(String userId, String docId) async {
    try {
      await _itineraryCollection
          .doc(userId)
          .collection('Itineraries')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error deleting itinerary item: $e');
    }
  }
}
