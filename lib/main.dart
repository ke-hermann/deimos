import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Import the new widgets
import 'widgets/app_drawer.dart';
import 'widgets/add_item_dialog.dart';
import 'database_helper.dart'; // Your database helper import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print("SQFlite FFI initialized for Desktop.");
  }
  runApp(MyApp());
}

// Keep Category enum here or move it to a separate models file if preferred
enum Category { bookmarks, playlists, tasks }

// --- Helper functions moved here to be easily passed to AppDrawer ---
// (Alternatively, they could be static methods in a helper class)
String getTitleForCategory(Category category) {
  switch (category) {
    case Category.bookmarks: return 'Bookmarks';
    case Category.playlists: return 'Playlists';
    case Category.tasks: return 'Tasks';
  }
}

IconData getIconForDrawerCategory(Category category) {
   switch (category) {
    case Category.bookmarks: return Icons.bookmark;
    case Category.playlists: return Icons.playlist_play;
    case Category.tasks: return Icons.task_alt;
    default: return Icons.list; // Should not happen with enum
  }
}

// Icon for the list items (can stay in _MyHomePageState or move here too)
IconData getIconForItem(Category category) {
   switch (category) {
    case Category.bookmarks: return Icons.bookmark_border;
    case Category.playlists: return Icons.library_music_outlined; // Example change
    case Category.tasks: return Icons.check_circle_outline;
    default: return Icons.list_alt;
  }
}
// --- End Helper Functions ---


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       title: 'All-In-One Manager',
       themeMode: ThemeMode.dark, // Or ThemeMode.system
       darkTheme: ThemeData.dark().copyWith(
         // Your dark theme customizations...
         colorScheme: ColorScheme.dark(
            primary: Colors.tealAccent[400]!,
            secondary: Colors.blueGrey[600]!,
            onSecondary: Colors.white, // Text on secondary color
            // Ensure other colors are suitable too
         ),
         appBarTheme: AppBarTheme( backgroundColor: Colors.grey[900], elevation: 4),
         floatingActionButtonTheme: FloatingActionButtonThemeData(
             backgroundColor: Colors.tealAccent[400], foregroundColor: Colors.black),
         drawerTheme: DrawerThemeData( backgroundColor: Colors.grey[850]),
         listTileTheme: ListTileThemeData(
             selectedTileColor: Colors.tealAccent.withOpacity(0.15)),
         dialogBackgroundColor: Colors.grey[800],
         // Add input decoration theme for dialog text field maybe
         inputDecorationTheme: const InputDecorationTheme(
           // Define styling for text fields globally or specifically
         ),
       ),
       theme: ThemeData( // Your light theme...
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
  List<String> _currentItems = [];
  bool _isLoading = false;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadItems(_selectedCategory);
  }

  // --- Database Interaction (keep as before) ---
  Future<void> _loadItems(Category category) async {
    if (mounted) setState(() => _isLoading = true);
    final items = await dbHelper.getItems(category);
    if (mounted) {
      setState(() {
        _currentItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _insertItem(String content) async {
    if (content.trim().isEmpty) return;
    await dbHelper.insertItem(_selectedCategory, content.trim());
    await _loadItems(_selectedCategory); // Refresh list
  }

  // --- Event Handlers ---

  // Called by AppDrawer
  void _onCategorySelected(Category category) {
    if (_selectedCategory != category) {
      if (mounted) {
        setState(() {
          _selectedCategory = category;
          // Trigger loading state immediately for smoother transition
          _isLoading = true;
          _currentItems = []; // Optionally clear old items immediately
        });
      }
      _loadItems(category); // Load items for the new category
    }
    Navigator.pop(context); // Close the drawer AFTER state update begins
  }

  // Called by FloatingActionButton onPressed
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use the new AddItemDialog widget
        return AddItemDialog(
          selectedCategory: _selectedCategory,
          // Pass the _insertItem method as the callback
          onAddItem: (newItemText) {
            _insertItem(newItemText);
            // Optional: Show confirmation SnackBar
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('"$newItemText" added!')),
            // );
          },
        );
      },
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use the global helper function
        title: Text(getTitleForCategory(_selectedCategory)),
      ),
      // Use the new AppDrawer widget
      drawer: AppDrawer(
        selectedCategory: _selectedCategory,
        onCategorySelected: _onCategorySelected,
        // Pass the global helper functions
        getTitleForCategory: getTitleForCategory,
        getIconForDrawerCategory: getIconForDrawerCategory,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        // Call the method that shows the refactored dialog
        onPressed: _showAddItemDialog,
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper widget to build the body content (keep as before)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentItems.isEmpty) {
      return Center(
        child: Text(
          'No items found in ${getTitleForCategory(_selectedCategory)}.\nTap + to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      itemCount: _currentItems.length,
      itemBuilder: (context, index) {
        final itemContent = _currentItems[index];
        return ListTile(
          // Use the global helper function for item icons
          leading: Icon(getIconForItem(_selectedCategory),
                     color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
          title: Text(itemContent),
          onTap: () {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tapped on: $itemContent (Action not implemented)'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          // Consider adding onLongPress for delete/edit later
        );
      },
    );
  }
} // End _MyHomePageState