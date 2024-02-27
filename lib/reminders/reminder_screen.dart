import 'package:flutter/material.dart';
import '../notes_screen.dart';
import '../components/menu_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addReminder.dart';
import 'reminder_box.dart';
import '../gallery/gallery_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import '../pages/login_or_register.dart';
import '../pages/auth_page.dart';
import 'reminder_reader.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../style/theme_class.dart';
import 'package:provider/provider.dart';
import '../style/customBottomNavigation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool isDarkAppBar = true; // Set the initial color to black
  int _currentIndex = 1;
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  void _onTabTapped(int index) {
    // final themeProvider =
    // Provider.of<ThemeProvider>(context, listen: false); // get the provider, listen false is necessary cause is in a function

    setState(() {
      _currentIndex = index;
      // isDarkAppBar = !isDarkAppBar;
    });

    // Navigate to the desired screen based on the index
    switch (index) {
      case 0:
        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: NotesScreen(), isIos: true));
        // Navigator.push(context, MaterialPageRoute(builder: (context) => NotesScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ReminderScreen()));

        break;
    // Add more cases for other screens
      case 2:
      // Navigate to the My Logo screen
        setState(() {
          isDarkAppBar = !isDarkAppBar; // Toggle between white and black
        });
        // isDarkAppBar // call the functions
        //     ? themeProvider.setLightMode()
        //     : themeProvider.setDarkmode();
        _currentIndex = 1;
        break;
      case 3:
      // Navigate to the Take Photo screen
      _pickImageFromCamera();
      Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
      break;
      case 4:
      // Navigate to the Gallery screen
        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: GalleryScreen()));
        // Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
        break;
    }
  }

  void navigateToNewScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return addReminder();
    }));
  }

  Future<String?> uploadImageToStorage(XFile image) async {
    final imageFile = File(image.path);
    final imageRef = FirebaseStorage.instance.ref().child('Gallery/${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      // upload the image to Firebase Storage
      await imageRef.putFile(imageFile);

      final imageUrl = await imageRef.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String> detectTextInImage(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);

    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin, // Replace with the desired language script
    );

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String detectedText = recognizedText.text;

    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints.map((point) {
        return Offset(point.x.toDouble(), point.y.toDouble());
      }).toList();
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }

    textRecognizer.close();

    return detectedText;
  }

  Future<void> cameraFunction() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage == null) return; // User canceled the image selection

    final XFile imageFile = pickedImage;

    // Upload the image to Firebase Storage
    final imageUrl = await uploadImageToStorage(imageFile);

    if (imageUrl != null) {
      // If the image was successfully uploaded, you can store the URL in Firestore
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      String detectedText = await detectTextInImage(pickedImage);

      if (detectedText.isNotEmpty) {
        // You can use the detected text as needed
        print('Detected Text: $detectedText');
      }

      await FirebaseFirestore.instance.collection('Gallery').add({
        'email': userEmail,
        'imageUrl': imageUrl,
        "detectedText": detectedText,
      });

      // Optionally, you can show a confirmation to the user here
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Image Uploaded'),
            content: Text('The image was successfully uploaded.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case where there was an error uploading the image
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload the image.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage == null) return; // User canceled the image selection

    final XFile imageFile = pickedImage;

    // Upload the image to Firebase Storage
    final imageUrl = await uploadImageToStorage(imageFile);

    if (imageUrl != null) {
      // If the image was successfully uploaded, you can store the URL in Firestore
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      await FirebaseFirestore.instance.collection('Gallery').add({
        'email': userEmail,
        'imageUrl': imageUrl,
      });

      // Optionally, you can show a confirmation to the user here
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Image Uploaded'),
            content: Text('The image was successfully uploaded.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case where there was an error uploading the image
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload the image.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void signUserOut() async {
    AuthService().signOut();
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
            color: Colors.black,
          )
        ],
        elevation: 0,
        title: RichText(
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("Reminder").where("userEmail", isEqualTo: userEmail).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if(snapshot.hasData) {
                    return GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                        childAspectRatio: (1 / .4),
                      ),
                      children: snapshot.data!.docs.map((reminder) => reminderBox(() {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ReminderReader(reminder),
                        ));
                      }, reminder)).toList(), //{
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => addReminder(),
                        // ));
                      // }, title)).toList(),
                    );
                  }
                  return Text("Ther's no reminder");
                },

              ),
            ),
          ],
        ),
      ),

      backgroundColor: Colors.grey[200],
      bottomNavigationBar: CustomBottomNavigation(
        addingThings: navigateToNewScreen,
        cameraFunction: cameraFunction,
      ),
    );
  }
}
