import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../style/app_style.dart';
import 'notes_main.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class NoteReaderScreen extends StatefulWidget {
  NoteReaderScreen(this.doc, {Key? key}) : super(key: key);
  QueryDocumentSnapshot doc;
  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _remarksController = TextEditingController();

  void updateDocument() {
    // Update the Firestore document with new data
    String newTitle = _titleController.text;
    String newRemarks = _remarksController.text;

    // Update the Firestore document with the new title and remarks
    FirebaseFirestore.instance
        .collection("Notes") // Replace with your collection name
        .doc(widget.doc.id) // Use the ID of the current document
        .update({
      "note_title": newTitle,
      "remarks": newRemarks,
    }).then((_) {
      // Show a success message or perform other actions after updating
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Note updated successfully"),
      ));
    }).catchError((error) {
      // Handle errors if the update fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating note: $error"),
      ));
    });
  }
  void deleteDocument() {
    FirebaseFirestore.instance
        .collection("Notes") // Replace with your collection name
        .doc(widget.doc.id) // Use the ID of the current document
        .delete()
        .then((_) {
      // Show a success message or perform other actions after deleting
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Note deleted successfully"),
      ));

      // Navigate back to the previous screen after deleting
      Navigator.of(context).pop();
    })
        .catchError((error) {
      // Handle errors if the delete fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error deleting note: $error"),
      ));
    });
  }
  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this note?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // User clicked "No"
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                // User clicked "Yes"
                deleteDocument();
                Navigator.of(context).pop();// Call your delete function here
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }



  @override
  void initState() {
    super.initState();
    _titleController.text = widget.doc["note_title"];
    _remarksController.text = widget.doc["remarks"];
  }
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';


  @override
  Widget build(BuildContext context) {
    String carName = '';
    int color_id = widget.doc['color_id'];
    return Scaffold(
      // backgroundColor: AppStyle.cardsColor[color_id],
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        // backgroundColor: AppStyle.cardsColor[color_id],
        backgroundColor: Colors.grey[300],
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // Use the appropriate back icon
            color: Colors.black, // Change the color here
          ),
          onPressed: () {
            // Handle the back button press
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              showDeleteConfirmationDialog();
            },
            color: Colors.red,
            iconSize: 40,
          )
        ],
      ),
        body: SingleChildScrollView(child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(widget.doc["note_title"], style: AppStyle.mainTitle),
              Align(
                alignment: Alignment(0.9,0),
                child: Text(
                  widget.doc["creation_date"],
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
              SizedBox(height: 18.0),
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
                        controller: _remarksController,
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
              SizedBox(height: 10,),

              Padding(
                padding: const EdgeInsets.only(right:16.0,top: 20,bottom: 20),
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      // Your save button logic here
                      updateDocument();
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => NotesMain(carName: carName)));
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black, // Background color
                      padding: EdgeInsets.all(20.0), // Padding to expand the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Border radius of 20
                      ),
                      minimumSize: Size(300,50),
                    ),
                    child: Text("Update Notes", style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
                  ),
                ),
              ),

            ],
        ),
        ),
        ),
    );
  }
}
