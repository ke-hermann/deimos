import 'package:flutter/material.dart';
// Import the database helper
import 'database_helper.dart';
import 'dart:io'; // Import dart:io to check the platform
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import the FFI package

void main() {
  // Ensure Flutter bindings are initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize FFI specifically for non-mobile platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for sqflite to use the FFI implementation
    databaseFactory = databaseFactoryFfi;
    print("SQFlite FFI initialized for Desktop."); // Optional: for confirmation
  }
  runApp(MyApp());
}

// Enum to represent the different categories (can stay here or move)
enum Category { bookmarks, playlists, tasks }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All-In-One Manager',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[700],
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent[400]!,
          secondary: Colors.blueGrey[600]!,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 4,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent[400],
          foregroundColor: Colors.black,
        ),
        drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[850]),
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.tealAccent.withOpacity(0.15),
        ),
        dialogBackgroundColor: Colors.grey[800],
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Category _selectedCategory = Category.bookmarks;
  List<String> _currentItems = []; // Holds items fetched from DB
  bool _isLoading = false; // To show loading indicator

  // Database helper instance
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    // Load initial data when the widget is first created
    _loadItems(_selectedCategory);
  }

  // --- Database Interaction ---

  Future<void> _loadItems(Category category) async {
    // Show loading indicator
    if (mounted) {
      // Check if widget is still in the tree
      setState(() {
        _isLoading = true;
      });
    }

    // Fetch items from database
    final items = await dbHelper.getItems(category);

    // Update state with fetched items and hide loading indicator
    if (mounted) {
      // Check again before calling setState
      setState(() {
        _currentItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _insertItem(String content) async {
    if (content.trim().isEmpty) return; // Avoid adding empty items

    await dbHelper.insertItem(_selectedCategory, content.trim());
    // Refresh the list after insertion
    await _loadItems(_selectedCategory);
  }

  // --- UI Helper Functions ---

  String _getTitleForCategory(Category category) {
    switch (category) {
      case Category.bookmarks:
        return 'Bookmarks';
      case Category.playlists:
        return 'Playlists';
      case Category.tasks:
        return 'Tasks';
    }
  }

  IconData _getIconForCategory(Category category) {
    switch (category) {
      case Category.bookmarks:
        return Icons.bookmark_border;
      case Category.playlists:
        return Icons.playlist_play;
      case Category.tasks:
        return Icons.check_circle_outline; // Changed task icon slightly
      default:
        return Icons.list;
    }
  }

  IconData _getIconForDrawerCategory(Category category) {
    switch (category) {
      case Category.bookmarks:
        return Icons.bookmark;
      case Category.playlists:
        return Icons.playlist_play;
      case Category.tasks:
        return Icons.task_alt; // Keep filled icon for drawer task
      default:
        return Icons.list;
    }
  }

  // --- Event Handlers ---

  void _onCategorySelected(Category category) {
    if (_selectedCategory != category) {
      if (mounted) {
        setState(() {
          _selectedCategory = category;
          // Don't clear _currentItems here, let _loadItems handle it
        });
      }
      _loadItems(category); // Load items for the new category
    }
    Navigator.pop(context); // Close the drawer
  }

  void _showAddItemDialog() {
    final TextEditingController textController = TextEditingController();
    final categoryName = _getTitleForCategory(_selectedCategory);
    String inputHint;

    switch (_selectedCategory) {
      case Category.bookmarks:
        inputHint = 'Enter bookmark URL or name';
        break;
      case Category.playlists:
        inputHint = 'Enter playlist name or link';
        break;
      case Category.tasks:
        inputHint = 'Enter task description';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add New $categoryName'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(hintText: inputHint),
            onSubmitted:
                (_) => _submitAddItemDialog(textController, dialogContext),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                textController.dispose(); // Dispose on cancel
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed:
                  () => _submitAddItemDialog(textController, dialogContext),
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure controller is disposed if dialog is dismissed otherwise
      // (less critical now since we dispose in actions, but safe)
      // textController.dispose(); // Already disposed in actions
    });
  }

  // Modified to be async and call _insertItem
  Future<void> _submitAddItemDialog(
    TextEditingController controller,
    BuildContext dialogContext,
  ) async {
    final String newItemText =
        controller.text; // No need to trim here, _insertItem will do it

    // Close the dialog FIRST to avoid context issues if _insertItem takes time
    Navigator.of(dialogContext).pop();

    // Insert the item into the database (this also reloads the list)
    await _insertItem(newItemText);

    controller.dispose(); // Dispose controller after use
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitleForCategory(_selectedCategory))),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.secondary, // Use theme color
              ),
              child: Text(
                'Categories',
                style: TextStyle(
                  // Adjust color for better contrast on secondary background
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 24,
                ),
              ),
            ),
            // Use Category.values.map for slightly cleaner drawer building
            ...Category.values.map(
              (category) => ListTile(
                leading: Icon(_getIconForDrawerCategory(category)),
                title: Text(_getTitleForCategory(category)),
                onTap: () => _onCategorySelected(category),
                selected: _selectedCategory == category,
                // selectedTileColor is handled by theme
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(), // Use helper function for body
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog, // Renamed _addItem to _showAddItemDialog
        tooltip: 'Add New Item',
        child: Icon(Icons.add),
      ),
    );
  }

  // Helper widget to build the body content based on loading state
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_currentItems.isEmpty) {
      return Center(
        child: Text(
          'No items found in ${_getTitleForCategory(_selectedCategory)}.\nTap + to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
      );
    }

    // Display the list using data from _currentItems
    return ListView.builder(
      itemCount: _currentItems.length,
      itemBuilder: (context, index) {
        final itemContent = _currentItems[index];
        return ListTile(
          leading: Icon(
            _getIconForCategory(_selectedCategory),
            color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
          ), // Use theme icon color
          title: Text(itemContent),
          onTap: () {
            // Add specific item action later
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tapped on: $itemContent (Action not implemented)',
                ),
                duration: Duration(seconds: 1),
              ),
            );
          },
          // Consider adding onLongPress for delete/edit later
        );
      },
    );
  }
}
