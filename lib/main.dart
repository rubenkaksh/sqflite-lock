import 'package:flutter/material.dart';
import 'database_service.dart';
import 'repositories/photo_repository.dart';
import 'models/photo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Fetcher',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Photo Fetcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseService _databaseService = DatabaseService();
  late final PhotoRepository _photoRepository;
  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _error;
  int attempt = 1;

  @override
  void initState() {
    super.initState();
    _photoRepository = PhotoRepository(_databaseService);
  }

  Future<void> _loadLocalPhotos() async {
    try {
      final photos = await _photoRepository.getLocalPhotos();
      setState(() {
        _photos = photos;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading local photos: $e';
      });
    }
  }

  fetchTogether() async {
    // Start fetching data in the background
     _fetchAndStorePhotos();

    Future.delayed(Duration(milliseconds: 1000), _loadLocalPhotos);
  }

  Future<void> _fetchAndStorePhotos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final photos =
          await _photoRepository.fetchAndStorePhotos(attempt: attempt);
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching photos: $e';
        _isLoading = false;
      });
    }
    attempt++;
  }

  Future<void> _clearPhotos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _photoRepository.clearLocalPhotos();
      setState(() {
        _photos = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error clearing photos: $e';
        _isLoading = false;
      });
    }
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : fetchTogether,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Fetch and Store Photos'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _clearPhotos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear All Photos'),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _photos.isEmpty
                ? const Center(child: Text('No photos available'))
                : RawScrollbar(
                    controller: scrollController,
                    thickness: 10,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        final photo = _photos[index];
                        return ListTile(
                          // leading: Image.network(
                          //   photo.thumbnailUrl,
                          //   width: 50,
                          //   height: 50,
                          //   fit: BoxFit.cover,
                          // ),
                          title: Text(photo.title),
                          subtitle: Text('Album ID: ${photo.id}'),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
