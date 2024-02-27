import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../style/app_style.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';


class NoteEditorScreen extends StatefulWidget {
  final String carName;
  const NoteEditorScreen({Key? key,required this.carName}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  int color_id = Random().nextInt(AppStyle.cardsColor.length);
  String date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());


  TextEditingController _titleController = TextEditingController();
  TextEditingController _mainController = TextEditingController();
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';



  @override
  Widget build(BuildContext context) {
    String carName = widget.carName;

    return Scaffold(
      resizeToAvoidBottomInset: true, // This will automatically resize the screen when the keyboard appears
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        // backgroundColor: AppStyle.cardsColor[color_id],
        backgroundColor: Colors.grey[200],
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        // title: Text("Add a new Note by adding Title & Content", style: TextStyle(color: Colors.black, fontSize: 16.0),),
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Add a new notes ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
              TextSpan(
                text: '(Title)',
                style: TextStyle(
                  color: Colors.red, // Change the color of "Title"
                  fontSize: 16.0,   // Change the fontsize of "Title"
                ),
              ),
              TextSpan(
                text: ' & ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
              TextSpan(
                text: '(Content)',
                style: TextStyle(
                  color: Colors.blue, // Change the color of "Content"
                  fontSize: 16.0,    // Change the fontsize of "Content"
                ),
              ),
            ],
          ),
        ),

      ),
      body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment(0.9,0),
              child: Text(
                date,
                style: AppStyle.dateTitle,
              ),
            ),
            SizedBox(height: 28.0),
            Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note Title',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter your Note Title Here',
                        hintStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        prefixIcon: Icon(
                          Icons.title,
                          color: Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      // Query Firestore to get matching note titles
                      final querySnapshot = await FirebaseFirestore.instance
                          .collection('Notes')
                          .where('email', isEqualTo: userEmail)
                          .where('carName', isEqualTo: carName)
                          .get();

                      final titles = querySnapshot.docs
                          .map((doc) => doc['note_title'] as String)
                          .toList();

                      return titles;
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _titleController.text = suggestion;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0,),

            Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Note Content',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.vertical, // Allow vertical scrolling
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  controller: _mainController,
                  maxLines: null, // Set maxLines to null for unlimited lines
                  decoration: InputDecoration(
                    hintText: 'Enter your Note Content Here',
                    hintStyle: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    prefixIcon: Icon(
                      Icons.note_alt,
                      color: Colors.black,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
            Padding(
              padding: const EdgeInsets.only(right:16.0,top: 20,bottom: 20),
              child: Center(
                child: TextButton(
                  onPressed: () async {
                    // Your save button logic here
                    // Validate the input fields
                    if (_titleController.text.isEmpty || _mainController.text.isEmpty) {
                      // Show an error message to prompt the user to enter the required information
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in both title and remarks fields.'),
                        ),
                      );
                      return; // Exit the onPressed function to prevent further execution
                    }

                    String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

                    FirebaseFirestore.instance.collection("Notes").add({
                      "email": userEmail,
                      "carName": carName,
                      "note_title": _titleController.text,
                      "creation_date": date,
                      "remarks": _mainController.text,
                      "color_id": color_id
                    }).then((value) {
                      Navigator.pop(context);
                    }).catchError((error) => print("Failed to add new Note due to $error"));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    padding: EdgeInsets.all(20.0), // Padding to expand the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Border radius of 20
                    ),
                    minimumSize: Size(300,50),
                  ),
                  child: Text("Save Notes", style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
                ),
              ),
            ),
          ],
        )
      ),

      ),


    );
  }
}
