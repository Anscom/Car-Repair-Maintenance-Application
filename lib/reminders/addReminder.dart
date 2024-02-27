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

class addReminder extends StatefulWidget {

  final String? title;
  final String? remarks;
  final String? nextService;

  addReminder({Key? key, this.title, this.remarks, this.nextService})
      : super(key: key);

  @override
  State<addReminder> createState() => _addReminderState();
}

class _addReminderState extends State<addReminder> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController nextServiceController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  DateTime? selectedDateTime;
  final int counter = 0;

  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    // Set the text controllers with the provided details
    titleController.text = widget.title ?? "";
    nextServiceController.text = widget.nextService ?? "";
    remarksController.text = widget.remarks ?? "";
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
            Icons.arrow_back,
            color: Colors.black,
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

                // Center the calendar icon and "Next Serviced" row
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
                              (widget.nextService?.isNotEmpty ?? false)
                                  ? widget.nextService!
                                  : (selectedDateTime != null)
                                  ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)
                                  : "Select Date and Time",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'Roboto',
                                color: Colors.black,
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
                            // Your save button logic here
                            // Get the user's email
                            String? userEmail = FirebaseAuth.instance.currentUser?.email;

                            if (userEmail != null) {
                              // Validate the input fields
                              if (titleController.text.isEmpty || selectedDateTime == null || remarksController.text.isEmpty) {
                                // Show a SnackBar with an error message for missing information
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill in all fields.'),
                                  ),
                                );
                                return; // Exit the onPressed function to prevent further execution
                              }
                              // Prepare data to be saved to Firestore
                              Map<String, dynamic> reminderData = {
                                'title': titleController.text,
                                'nextService': selectedDateTime != null
                                    ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)
                                    : '',
                                'remarks': remarksController.text,
                                'userEmail': userEmail,
                                'notificationCounter': NotificationService.getCounter(),
                              };

                              try {
                                // Save the data to Firestore
                                await FirebaseFirestore.instance.collection('Reminder').add(reminderData);


                                // Show a success message using a SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reminder saved successfully.'),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReminderScreen()),
                                );

                                // Navigator.popUntil(context, (route) => route.isFirst);



                              } catch (error) {
                                // Handle any potential errors, e.g., display an error message
                                print('Error saving reminder: $error');
                              }
                            }
                            if (selectedDateTime != null) {
                              notificationService.scheduleNotification(
                                title: titleController.text,
                                body: remarksController.text,
                                scheduledNotificationDateTime: selectedDateTime!,
                              );
                            } else {
                              // Handle the case when selectedDateTime is null
                              print("Please select a date and time");
                            };
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black, // Background color
                            padding: EdgeInsets.all(20.0), // Padding to expand the button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Border radius of 20
                            ),
                            minimumSize: Size(300,50),
                          ),
                          child: Text("Save Reminder", style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
                        ),
                      ),
                    ),

              ],
            ),
      ),
        ),
      // ),
      ),
    );
  }

}
