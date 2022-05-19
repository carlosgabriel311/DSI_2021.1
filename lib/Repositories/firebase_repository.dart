import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepository {
  final List<Word> _suggestions = [];
  final List<Word> _favorites = [];
  late CollectionReference wordsCollection;
  late CollectionReference favoriteCollection;

  initialazeRepository() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDKwmnZHy07mp01WVNnued-ROwxiVge_Vk",
          authDomain: "dsi-2020-1.firebaseapp.com",
          projectId: "dsi-2020-1",
          storageBucket: "dsi-2020-1.appspot.com",
          messagingSenderId: "291014176240",
          appId: "1:291014176240:web:4f0369e1af1854d91d0135"),
    );
    wordsCollection = FirebaseFirestore.instance.collection('Words');
    favoriteCollection = FirebaseFirestore.instance.collection('Favorites');
    await _initializeSuggestions();
    await _initializeFavorites();
  }

  Future<void> _initializeSuggestions() async {
    QuerySnapshot result = await wordsCollection.get();
    for (var doc in result.docs) {
      _suggestions.add(Word(doc.id, doc['primeira'], doc['segunda']));
    }
  }

  Future<void> _initializeFavorites() async {
    QuerySnapshot result = await favoriteCollection.get();
    for (var doc in result.docs) {
      _favorites.add(Word(doc.id, doc['primeira'], doc['segunda']));
    }
  }

  void createSuggestion() {
    for (var i = 0; i < 20; i++) {
      Timestamp id = Timestamp.now();
      var word = generateWordPairs().first;
      wordsCollection.doc(id.toString()).set(
        {'primeira': word.first, 'segunda': word.second},
      );
      _suggestions.add(Word(id.toString(), word.first, word.second));
    }
  }

  void removeSuggestion(Word word) {
    wordsCollection.doc(word.id).delete();
    _suggestions.remove(word);
  }

  /*void updateWorPair(int id, String primeira, String segunda) {
    var collection = FirebaseFirestore.instance.collection('Words');
    collection.doc('$id').update(
      {
        'primeira': primeira,
        'segunda': segunda,
      },
    );
  }*/

  getWordPairs(int key) {
    return _suggestions[key];
  }

  getSize() {
    return _suggestions.length;
  }

  bool isFavorite(Word pair) {
    return _favorites.any((element) => element.id == pair.id);
  }

  void addToFavorites(Word pair) {
    favoriteCollection.doc(pair.id).set(
      {
        'primeira': pair.first,
        'segunda': pair.second,
      },
    );
    _favorites.add(pair);
  }

  void removeFavorite(Word pair) {
    favoriteCollection.doc(pair.id).delete();
    _favorites.removeWhere(((element) => element.id == pair.id));
  }

  List getFavorites() {
    return _favorites;
  }
}

class Word {
  String id;
  String first;
  String second;
  Word(this.id, this.first, this.second);

  String asPascalCase() {
    return first[0].toUpperCase() +
        first.substring(1) +
        second[0].toUpperCase() +
        second.substring(1);
  }
}
