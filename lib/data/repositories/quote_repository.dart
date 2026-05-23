import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/quote_model.dart';

class QuoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveQuote(QuoteModel quote) async {
    await _firestore.collection('quotes').doc(quote.id).set(quote.toMap());
  }

  Stream<List<QuoteModel>> getUserQuotes(String userId) {
    return _firestore
        .collection('quotes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => QuoteModel.fromMap(d.data())).toList());
  }
}
