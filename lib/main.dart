import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Enum to represent the different categories
enum Category { bookmarks, videos, tasks }

// main() and Category enum remain the same
// MyHomePage and _MyHomePageState remain the same

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All-In-One Manager',
      themeMode: ThemeMode.dark, // Force dark mode
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

  // --- Placeholder Data ---
  final Map<Category, List<String>> _items = {
    Category.bookmarks: [
      'https://flutter.dev',
      'https://dart.dev/language',
      'https://m3.material.io/'
    ],
    Category.videos: [
      'Spotify: Chill Vibes Mix',
      'YouTube Music: Workout Beats',
      'Local: Focus Study'
    ],
    Category.tasks: [
      'Implement Add Item Dialog',
      'Refactor data storage',
      'Design item detail view'
    ],
  };
  // --- End Placeholder Data ---

  String _getTitleForCategory(Category category) {
    switch (category) {
      case Category.bookmarks:
        return 'Bookmarks';
      case Category.videos:
        return 'Videos';
      case Category.tasks:
        return 'Tasks';
    }
  }

  IconData _getIconForCategory(Category category) {
    switch (category) {
      case Category.bookmarks:
        return Icons.bookmark_border; // Use border version for list items maybe
      case Category.videos:
        return Icons.playlist_play;
      case Category.tasks:
        return Icons.task_alt;
    }
  }

   // Icon for the drawer specifically
   IconData _getIconForDrawerCategory(Category category) {
     switch (category) {
      case Category.bookmarks:
        return Icons.bookmark; // Filled version for drawer
      case Category.videos:
        return Icons.playlist_play;
      case Category.tasks:
        return Icons.task_alt;
    }
  }

  void _onCategorySelected(Category category) {
    setState(() {
      _selectedCategory = category;
    });
    Navigator.pop(context);
  }

  void _addItem() {
    // Controller to manage the text field's input
    final TextEditingController textController = TextEditingController();
    final categoryName = _getTitleForCategory(_selectedCategory);
    String inputHint;

    // Customize hint text based on category
    switch (_selectedCategory) {
      case Category.bookmarks:
        inputHint = 'Enter bookmark URL or name';
        break;
      case Category.videos:
        inputHint = 'Enter playlist name or link';
        break;
      case Category.tasks:
        inputHint = 'Enter task description';
        break;
    }


    // Show the dialog
    showDialog(
      context: context,
      // Prevent dismissing by tapping outside if needed (optional)
      // barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add New $categoryName'),
          content: TextField(
            controller: textController,
            autofocus: true, // Automatically focus the text field
            decoration: InputDecoration(hintText: inputHint),
             // You could change keyboard type based on category if needed
             // keyboardType: _selectedCategory == Category.bookmarks
             //     ? TextInputType.url
             //     : TextInputType.text,
            onSubmitted: (_) => _submitAddItemDialog(textController), // Optional: allow submitting with keyboard action
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            ElevatedButton( // Make the 'Add' button more prominent
              child: Text('Add'),
              onPressed: () => _submitAddItemDialog(textController),
            ),
          ],
        );
      },
    );
  }

  // Helper function to handle submission from dialog
  void _submitAddItemDialog(TextEditingController controller) {
     final String newItemText = controller.text.trim(); // Trim whitespace

      if (newItemText.isNotEmpty) {
        setState(() {
          // Add the item to the correct list
          _items[_selectedCategory]?.add(newItemText);
        });
         Navigator.of(context).pop(); // Close the dialog (use the main context)
         controller.dispose(); // Dispose controller after use
      } else {
        // Optional: Show an error if the input is empty
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Input cannot be empty.'),
            backgroundColor: Colors.redAccent,
             duration: Duration(seconds: 2),
          ),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> currentItems = _items[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForCategory(_selectedCategory)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              // Use specific drawer icon
              leading: Icon(_getIconForDrawerCategory(Category.bookmarks)),
              title: Text(_getTitleForCategory(Category.bookmarks)),
              onTap: () => _onCategorySelected(Category.bookmarks),
              selected: _selectedCategory == Category.bookmarks,
              selectedTileColor: Colors.blue.withOpacity(0.1),
            ),
            ListTile(
              leading: Icon(_getIconForDrawerCategory(Category.videos)),
              title: Text(_getTitleForCategory(Category.videos)),
              onTap: () => _onCategorySelected(Category.videos),
               selected: _selectedCategory == Category.videos,
               selectedTileColor: Colors.blue.withOpacity(0.1),
            ),
            ListTile(
              leading: Icon(_getIconForDrawerCategory(Category.tasks)),
              title: Text(_getTitleForCategory(Category.tasks)),
              onTap: () => _onCategorySelected(Category.tasks),
              selected: _selectedCategory == Category.tasks,
              selectedTileColor: Colors.blue.withOpacity(0.1),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: currentItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            // Use the general category icon for list items
            leading: Icon(_getIconForCategory(_selectedCategory), color: Colors.grey[600]),
            title: Text(currentItems[index]),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped on: ${currentItems[index]} (Action not implemented)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
             // Add long press for deletion later?
             // onLongPress: () { /* Implement deletion */},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Add New Item',
        child: Icon(Icons.add),
      ),
    );
  }
}