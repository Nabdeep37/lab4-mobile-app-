import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon Cards',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.lightGreenAccent,
          secondary: Colors.purpleAccent,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  void _startSplashScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Duration of the splash screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Pokemon Cards')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/logo.png'), // Replace with your logo asset
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _cards = [];
  List<dynamic> _filteredCards = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isListView = true; // Default to ListView
  TextEditingController _searchController = TextEditingController();
  dynamic _selectedCard;

  @override
  void initState() {
    super.initState();
    _fetchPokemonCards();
  }

  Future<void> _fetchPokemonCards() async {
    final response = await http.get(
      Uri.parse('https://api.pokemontcg.io/v2/cards'),
      headers: {'X-Api-Key': '1e29fd45-302a-4df2-9157-7cc5cb96b667'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _cards = data['data'];
        _filteredCards = _cards;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCardTapped(dynamic card) {
    setState(() {
      _selectedCard = card;
    });
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(
                            _selectedCard['images']['large'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _selectedCard['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Set: ${_selectedCard['set']['name'] ?? "No set name"}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Rarity: ${_selectedCard['rarity'] ?? "Unknown"}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSearchPressed() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _filteredCards = _cards;
        _searchController.clear();
      }
    });
  }

  void _onSettingsPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showHistory();
                },
                child: const Text('View Search History'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHistory() {
    // Implement your logic to show search history
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search History'),
          content: Text('This is where search history will be displayed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _filterCards(String query) {
    final filtered = _cards.where((card) {
      final name = card['name'].toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      _filteredCards = filtered;
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isListView = !_isListView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search cards...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _filterCards,
          onSubmitted: (query) {
            _filterCards(query);
          },
        )
            : Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _onSearchPressed,
          ),
          IconButton(
            icon: Icon(_isListView ? Icons.grid_view : Icons.list),
            onPressed: _toggleViewMode,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _onSettingsPressed,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isListView
          ? _buildListView()
          : _buildGridView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: _filteredCards.length,
      itemBuilder: (context, index) {
        final card = _filteredCards[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                card['images']['small'],
                width: 100,
                height: 100,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Set: ${card['set']['name'] ?? "No set name"}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Rarity: ${card['rarity'] ?? "Unknown"}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _onCardTapped(card),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2 / 3,
      ),
      itemCount: _filteredCards.length,
      itemBuilder: (context, index) {
        final card = _filteredCards[index];
        return GestureDetector(
          onTap: () => _onCardTapped(card),
          child: Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.network(
                    card['images']['small'],
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    card['name'] ?? 'No Name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
