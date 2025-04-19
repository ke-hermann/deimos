import 'package:flutter/material.dart';
import '../../main.dart'; // Import Category enum (adjust path if main.dart is elsewhere)

class AddItemDialog extends StatefulWidget {
  final Category selectedCategory;
  // Callback function to execute when an item is successfully added
  final Function(String) onAddItem;

  const AddItemDialog({
    super.key,
    required this.selectedCategory,
    required this.onAddItem,
  });

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late final TextEditingController _textController;
  String _inputHint = ''; // To store the hint text
  String _dialogTitle = ''; // To store the dialog title

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _updateDialogText(); // Set initial text based on category
  }

  // Helper to set title and hint based on the category
  void _updateDialogText() {
    switch (widget.selectedCategory) {
      case Category.bookmarks:
        _dialogTitle = 'Add New Bookmark';
        _inputHint = 'Enter bookmark URL or name';
        break;
      case Category.playlists:
        _dialogTitle = 'Add New Playlist';
        _inputHint = 'Enter playlist name or link';
        break;
      case Category.tasks:
        _dialogTitle = 'Add New Task';
        _inputHint = 'Enter task description';
        break;
    }
  }

  @override
  void dispose() {
    _textController.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  void _submit() {
    final String newItemText = _textController.text.trim();
    if (newItemText.isNotEmpty) {
      widget.onAddItem(newItemText); // Call the callback provided by the parent
      Navigator.of(context).pop(); // Close the dialog
    } else {
      // Optional: Show an error within the dialog or using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Input cannot be empty.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_dialogTitle),
      content: TextField(
        controller: _textController,
        autofocus: true,
        decoration: InputDecoration(hintText: _inputHint),
        onSubmitted: (_) => _submit(), // Allow submitting with keyboard action
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'), // Call the internal submit method
        ),
      ],
    );
  }
}