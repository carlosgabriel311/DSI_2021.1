// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class Words {
  final _suggestions = <Word>[];
  final _favorites = <Word>{};
  bool _view = true;

  Words() {
    generateSuggestion(20);
  }

  void generateSuggestion(int count) {
    for (var i = 0; i < count; i++) {
      _suggestions.add(Word());
    }
  }

  List getAllSuggestions() {
    return _suggestions;
  }

  Word getSuggestionByIndex(int index) {
    return _suggestions[index];
  }

  void removeSuggestion(Word value) {
    _suggestions.remove(value);
  }

  void addToFavorites(Word value) {
    _favorites.add(value);
  }

  void removeFavorite(Word value) {
    _favorites.remove(value);
  }

  Set getAllFavorites() {
    return _favorites;
  }

  bool isFavorite(Word value) {
    return _favorites.contains(value);
  }

  bool view() {
    return _view;
  }
  void alterView(bool value){
    _view = value;
  }
}

class Word {
  String first = '';
  String second = '';

  Word() {
    var word = generateWordPairs().first;
    first = word.first;
    second = word.second;
  }

  String asPascalCase() {
    return first[0].toUpperCase() +
        first.substring(1) +
        second[0].toUpperCase() +
        second.substring(1);
  }
}

Words words = Words();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generetor',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      initialRoute: '/',
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        EditScreen.routeName: (context) => const EditScreen(),
        SaveScreen.routeName: (context) => const SaveScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/saved'),
            icon: const Icon(Icons.favorite),
            tooltip: 'Saved Suggestions',
          ),
        ],
        leading: IconButton(
          onPressed: () {
            setState(
              () {
                words.view() ? words.alterView(false) : words.alterView(true);
              },
            );
          },
          icon: Icon(words.view() ? Icons.grid_view : Icons.list),
          tooltip: 'alter visualization',
        ),
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    if (words.view()) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();
          final index = i ~/ 2;
          if (index >= words.getAllSuggestions().length) {
            words.generateSuggestion(10);
          }
          return _buildRow(words.getSuggestionByIndex(index));
        },
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 4,
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (context, i) {
          if (i >= words.getAllSuggestions().length) {
            words.generateSuggestion(10);
          }
          return Card(child: _buildRow(words.getSuggestionByIndex(i)));
        },
      );
    }
  }

  Widget _buildRow(Word pair) {
    final alreadySaved = words.isFavorite(pair);
    return Dismissible(
      key: Key(pair.toString()),
      onDismissed: (direction) {
        setState(() {
          words.removeSuggestion(pair);
          words.removeFavorite(pair);
        });
      },
      child: ListTile(
        title: Text(
          pair.asPascalCase(),
          style: _biggerFont,
        ),
        trailing: IconButton(
          icon: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border),
          color: alreadySaved ? Colors.red : null,
          tooltip: alreadySaved ? 'remove from saved' : 'Save',
          onPressed: () {
            setState(() {
              if (alreadySaved) {
                words.removeFavorite(pair);
              } else {
                words.addToFavorites(pair);
              }
            });
          },
        ),
        onTap: () => Navigator.pushNamed(context, '/edit', arguments: pair),
      ),
    );
  }
}

class SaveScreen extends StatelessWidget {
  const SaveScreen({Key? key}) : super(key: key);
  static const routeName = '/saved';

  @override
  Widget build(BuildContext context) {
    final tiles = words.getAllFavorites().map((pair) {
      return ListTile(
        title: Text(
          pair.asPascalCase(),
          style: const TextStyle(fontSize: 18.0),
        ),
      );
    });
    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
        : <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Suggestions'),
      ),
      body: ListView(children: divided),
    );
  }
}

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);
  static const routeName = '/edit';

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    final _palavra = ModalRoute.of(context)!.settings.arguments as Word;
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validarEntrada(value!),
                initialValue: _palavra.first,
                onSaved: (texto) => _palavra.first = texto.toString(),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validarEntrada(value!),
                initialValue: _palavra.second,
                onSaved: (texto) => _palavra.second = texto.toString(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("successfully")));
                  Navigator.popAndPushNamed(context, '/');
                }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  String? _validarEntrada(String value) {
    if (value.isEmpty) {
      return 'Informe um valor';
    }
    return null;
  }
}
