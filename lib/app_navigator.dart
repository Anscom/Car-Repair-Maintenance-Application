import 'package:flutter/material.dart';
import 'notes_screen.dart';

class AppNavigator extends StatefulWidget {
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {

  int _currentIndex = 0;

  // Define your screens here (exclude NotesScreen)
  List<Widget> _screens = [
    NotesScreen(),
    Text('Reminder Screen'),
    Text('My Logo'),
    Text('Take Photo Screen'),
    Text('Gallery Screen'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _currentIndex < _screens.length
            ? _screens[_currentIndex]
            : Text('Invalid Index'),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            canvasColor: Colors.black,
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.sticky_note_2),
                label: 'Notes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Reminder',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'My Logo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Take Photo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library),
                label: 'Gallery',
              ),
            ],
            currentIndex: _currentIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}



