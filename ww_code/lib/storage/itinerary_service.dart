
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
        data['id'] = doc.id;
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
            'title': itinerary['title'],
            'description': itinerary['description'],
            'startDate': itinerary['startDate'],
            'endDate': itinerary['endDate'],
          });
      itinerary['id'] = docRef.id;
    } catch (e) {
      print('Error saving itinerary to Firestore: $e');
    }
  }

  Future<void> updateItinerary(String userId, Map<String, dynamic> itinerary) async {
    String docId = itinerary['id'];
    try {
      await _itineraryCollection
          .doc(userId)
          .collection('Itineraries')
          .doc(docId)
          .update({
            'title': itinerary['title'],
            'description': itinerary['description'],
            'startDate': itinerary['startDate'],
            'endDate': itinerary['endDate'],
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
