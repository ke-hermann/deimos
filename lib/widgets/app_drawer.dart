import 'package:flutter/material.dart';
import '../../main.dart'; // Import Category enum and helper functions (adjust path)

class AppDrawer extends StatelessWidget {
  final Category selectedCategory;
  // Callback function when a category is tapped
  final Function(Category) onCategorySelected;
  // Pass helper functions needed within the drawer
  final String Function(Category) getTitleForCategory;
  final IconData Function(Category) getIconForDrawerCategory;


  const AppDrawer({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.getTitleForCategory,
    required this.getIconForDrawerCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary, // Use theme color
            ),
            child: Text(
              'Categories',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 24,
              ),
            ),
          ),
          // Build list tiles for each category dynamically
          ...Category.values.map((category) => ListTile(
                leading: Icon(getIconForDrawerCategory(category)), // Use passed function
                title: Text(getTitleForCategory(category)),       // Use passed function
                onTap: () => onCategorySelected(category), // Call the callback
                selected: selectedCategory == category,
                // selectedTileColor is handled by the theme in MaterialApp
              )),
        ],
      ),
    );
  }
}