import 'package:flutter/material.dart';
import 'package:carrepair/notes_screen.dart';
import '../reminders/reminder_screen.dart';

class CustomMenuBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final List<Widget> screenDestinations;
  final bool isDarkAppBar;


  CustomMenuBar({required this.currentIndex, required this.onTabTapped, required this.screenDestinations, required this.isDarkAppBar});

  @override
  _CustomMenuBarState createState() => _CustomMenuBarState();
}

class _CustomMenuBarState extends State<CustomMenuBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          // canvasColor: widget.isDarkAppBar ? Colors.black : Colors.white,
          canvasColor: Colors.grey[300],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTabTapped,
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
              icon: Icon(Icons.shield_moon_outlined),
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
          selectedItemColor: widget.isDarkAppBar ? Colors.black : Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
