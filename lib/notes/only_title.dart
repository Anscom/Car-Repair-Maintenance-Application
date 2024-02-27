import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Title {
  final String title;

  const Title({
    required this.title,
  });
}

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? ''; // Get the user's email

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Notes")
          .where("email", isEqualTo: userEmail) // Filter by user's email
          .where("carName", isEqualTo: "YourCarName") // Replace with your carName criteria
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No matching notes found.'),
          );
        }
        // Retrieve titles from matching notes
        final titles = snapshot.data!.docs.map((note) {
          return Title(title: note["note_title"] as String);
        }).toList();

        // You can now use the 'titles' list to display titles in your UI
        return ListView(
          children: titles.map((title) {
            return ListTile(
              title: Text(title.title),
            );
          }).toList(),
        );
      },
    );
  }
}
