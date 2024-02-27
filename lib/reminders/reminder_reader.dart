import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'reminder_screen.dart';
import '../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ReminderReader extends StatefulWidget {

  ReminderReader(this.doc, {Key ? key}) : super(key: key);
  QueryDocumentSnapshot doc;

  @override
  State<ReminderReader> createState() => _ReminderReaderState();
}

class _ReminderReaderState extends State<ReminderReader> {
  TextEditingController titleController = TextEditingController();
  TextEditingController nextServiceController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  DateTime? selectedDateTime;
  final int counter = 0;


  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.doc["title"];
    nextServiceController.text = widget.doc["nextService"];
    remarksController.text = widget.doc["remarks"];
  }

  void updateDocument() {
    // Update the Firestore document with new data
    String newTitle = titleController.text;
    String newNextServiced = selectedDateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)
        : nextServiceController.text;
    String newRemarks = remarksController.text;

    // Update the Firestore document with the new title and remarks
    FirebaseFirestore.instance
        .collection("Reminder") // Replace with your collection name
        .doc(widget.doc.id) // Use the ID of the current document
        .update({
      "title": newTitle,
      "nextService": newNextServiced,
      "remarks": newRemarks,
    }).then((_) {
      // Show a success message or perform other actions after updating
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Reminder updated successfully"),
      ));
    }).catchError((error) {
      // Handle errors if the update fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating reminder: $error"),
      ));
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReminderScreen()));
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
    await initializeDateFormatting('ms_MY', null);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // Format the selectedDateTime using the Malaysian locale
          final String formattedDateTime =
          DateFormat.yMMMMd('ms_MY H:mm').format(selectedDateTime!);

          // Print the formatted date and time
          print(formattedDateTime);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
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
        title: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Reminder',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 30.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              String? userEmail = FirebaseAuth.instance.currentUser?.email;

              if (userEmail != null) {
                // Query Firestore to find the reminder based on criteria
                QuerySnapshot remindersQuery = await FirebaseFirestore.instance
                    .collection('Reminder')
                    .where('userEmail', isEqualTo: userEmail)
                    .where('title', isEqualTo: titleController.text)
                    .where('nextService',
                    isEqualTo: nextServiceController.text)
                    .where('remarks', isEqualTo: remarksController.text)
                    .get();


                // Check if any reminders match the criteria
                if (remindersQuery.docs.isNotEmpty) {
                  // Display a confirmation dialog
                  bool deleteConfirmed = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete this reminder?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // User canceled
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // User confirmed
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  // If the user confirmed the deletion, proceed with deletion
                  if (deleteConfirmed) {
                    // Delete each matching reminder document
                    for (QueryDocumentSnapshot reminderDoc in remindersQuery.docs) {
                      await FirebaseFirestore.instance
                          .collection('Reminder')
                          .doc(reminderDoc.id)
                          .delete();
                    }
                    for (QueryDocumentSnapshot reminderDoc in remindersQuery.docs) {
                      // Access the 'notificationCounter' field from the document
                      int notificationCounter = reminderDoc['notificationCounter'];
                      notificationService.cancelScheduledNotification(notificationCounter);
                    }

                    // Show a success message using a SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reminder deleted successfully.'),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReminderScreen()),
                    );
                    // Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReminderScreen()));
                  }
                } else {
                  // If no reminders match the criteria, display a message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No matching reminder found.'),
                    ),
                  );
                }
              }
            },
            color: Colors.red,
            iconSize: 40,
          )
        ],
        centerTitle: true,
      ),
      // backgroundColor: Color(0xFFAFAFAF),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder Title',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Enter your Reminder Title Here',
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
                              Icons.title, // Use the icon you prefer
                              color: Colors.black, // Icon color
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 80,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: ListTile(
                            title: Center(child:Text('Next Serviced:', style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ))),
                            subtitle: GestureDetector(
                              onTap: () => _selectDateAndTime(context),
                              child: Container(
                                height: 50.0, // Set the desired height
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),child: Center(child:Text(
                                selectedDateTime != null
                                    ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)
                                    : nextServiceController.text,
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt,
                          size: 80,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: ListTile(
                            title: Center(child:Text('Remarks:', style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),),),
                            subtitle: Container(
                              height: 50.0, // Set the desired height
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10.0),
                              ),child:Center(child:TextField(
                              controller: remarksController,
                              decoration: InputDecoration(hintText: 'Enter Some remarks', hintStyle: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'Roboto',
                                color: Colors.black,

                              ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 35.0),
                                border: InputBorder.none, // Remove the bottom border
                              ),
                            ),),
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
                          updateDocument();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black, // Background color
                          padding: EdgeInsets.all(20.0), // Padding to expand the button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // Border radius of 20
                          ),
                          minimumSize: Size(300,50),
                        ),
                        child: Text("Update Reminder", style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      // ),
    );
  }

}
