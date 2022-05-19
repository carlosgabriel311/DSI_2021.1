import 'package:flutter/material.dart';
import 'package:startup_namer/Repositories/firebase_repository.dart';

FirebaseRepository words = FirebaseRepository();
bool view = true;

void main() async {
  await words.initialazeRepository();
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
                view ? view = false : view = true;
              },
            );
          },
          icon: Icon(view ? Icons.grid_view : Icons.list),
          tooltip: 'alter visualization',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          EditScreen.routeName,
          arguments: Word('', '', ''),
        ),
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromRGBO(0, 0, 255, 0.4),
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    if (view) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();
          final index = i ~/ 2;
          if (index >= words.getSize()) {
            words.createSuggestions();
          }
          return _buildRow(words.getWordPairs(index));
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
        itemBuilder: (context, index) {
          if (index >= words.getSize()) {
            words.createSuggestions();
          }
          return Card(child: _buildRow(words.getWordPairs(index)));
        },
      );
    }
  }

  Widget _buildRow(Word pair) {
    final alreadySaved = words.isFavorite(pair);
    return Dismissible(
      key: Key(pair.id),
      onDismissed: (direction) {
        setState(() {
          words.removeSuggestion(pair);
          words.removeFavorite(pair);
        });
      },
      child: ListTile(
        title: Text(
          pair.asPascalCase(),
          style: const TextStyle(
            fontSize: 18,
          ),
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
    final tiles = words.getFavorites().map((pair) {
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
    bool isNewSuggestion = _palavra.id.isEmpty;
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: isNewSuggestion
            ? const Text('create Page')
            : const Text('Edit Page'),
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
                onSaved: (text) => _palavra.first = text.toString(),
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
                onSaved: (text) => _palavra.second = text.toString(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (isNewSuggestion) {
                    words.addUserSuggestion(_palavra);
                  } else {
                    words.updateWord(_palavra);
                  }
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
