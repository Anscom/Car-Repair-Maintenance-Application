import 'package:flutter/material.dart';
import 'addCar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './pages/auth_page.dart';
import 'app_navigator.dart';
import './components/menu_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './notes/notes_main.dart';
import './cars/car_box.dart';
import './reminders/reminder_screen.dart';
import './gallery/gallery_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import './pages/login_or_register.dart';
import '../services/auth_service.dart';
import './style/theme_class.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './style/customBottomNavigation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {

  void signUserOut() async{
    AuthService().signOut();
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthPage()));
  }
  int _currentIndex = 0;
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  // void _onTabTapped(int index) async {
  //   // final themeProvider =
  //   // Provider.of<ThemeProvider>(context, listen: false); // get the provider, listen false is necessary cause is in a function
  //
  //   setState(() {
  //     _currentIndex = index;
  //     // isDarkAppBar = !isDarkAppBar;
  //
  //   });
  //
  //   // Navigate to the desired screen based on the index
  //   switch (index) {
  //     case 0:
  //       Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: NotesScreen(), isIos: true));
  //       break;
  //     case 1:
  //       Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: ReminderScreen()));
  //       // Navigator.push(context, MaterialPageRoute(builder: (context) => ReminderScreen()));
  //       break;
  //     case 2:
  //     // Navigate to the My Logo screen
  //     setState(() {
  //       isDarkAppBar = !isDarkAppBar; // Toggle between white and black
  //     });
  //     //   isDarkAppBar // call the functions
  //     //       ? themeProvider.setLightMode()
  //     //       : themeProvider.setDarkmode();
  //
  //       _currentIndex = 0;
  //
  //     break;
  //     case 3:
  //     // Navigate to the Take Photo screen
  //       _pickImageFromCamera();
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
  //       break;
  //     case 4:
  //     // Navigate to the Gallery screen
  //       Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: GalleryScreen()));
  //       // Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
  //       break;
  //   }
  // }

  void navigateToNewScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return addCar();
    }));
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

  Future<String?> getImageUrlForCurrentUser() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      // Query Firestore to get the document for the current user
      QuerySnapshot emailQuery = await FirebaseFirestore.instance
          .collection('UserData')
          .where('email', isEqualTo: userEmail)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        // Get the first document (assuming there's only one matching document)
        DocumentSnapshot userDocument = emailQuery.docs.first;

        // Access the "UserData" document and retrieve the "imageUrl" field
        String? imageUrl = userDocument.get('imageUrl'); // these 2 lines creating error
        return imageUrl;
      }
    }

    // Return null if the image URL couldn't be found
    return null;
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
                text: 'Car Selection',
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
                stream: FirebaseFirestore.instance.collection("UserData").where("email", isEqualTo: userEmail).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: (1 / 0.7),
                      ),
                      children: snapshot.data!.docs.map((car) {
                        final carData = car.data() as Map<String, dynamic>;
                        if (carData.containsKey('carName')) {
                          String carName = carData['carName'];
                          return GestureDetector(
                            onLongPress: () async {
                              final String carName = carData['carName'];
                              final String imageUrl = carData['imageUrl'];
                              final String userEmail = carData['email'];

                              // Show the first confirmation dialog
                              final bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete $carName?'),
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

                              if (confirmDelete == true) {
                                // User confirmed, proceed with deletion
                                try {
                                  // Delete the documents where all three fields match in the "UserData" collection
                                  await FirebaseFirestore.instance.collection("UserData")
                                      .where("carName", isEqualTo: carName)
                                      .where("imageUrl", isEqualTo: imageUrl)
                                      .where("email", isEqualTo: userEmail)
                                      .get()
                                      .then((querySnapshot) {
                                    querySnapshot.docs.forEach((doc) {
                                      doc.reference.delete();
                                    });
                                  });

                                  // Delete the notes where "carName" and "email" match in the "Notes" collection
                                  await FirebaseFirestore.instance.collection("Notes")
                                      .where("carName", isEqualTo: carName)
                                      .where("email", isEqualTo: userEmail)
                                      .get()
                                      .then((querySnapshot) {
                                    querySnapshot.docs.forEach((doc) {
                                      doc.reference.delete();
                                    });
                                  });

                                  // Show a deletion confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Deleted'),
                                        content: Text('Item deleted: $carName'),
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
                                } catch (e) {
                                  print('Error deleting item: $e');
                                  // Handle the error if needed
                                }
                              }
                            },
                            child: carBox((carName) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => NotesMain(carName: carName)));
                            }, car),
                          );
                        }
                        return Container(); // Handle the case where 'carName' doesn't exist in the document
                      }).toList(),
                    );
                  }
                  return Text("Ther's no car");
                },

              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: CustomBottomNavigation(
        addingThings: navigateToNewScreen,
          cameraFunction: cameraFunction,
      ),
    );
  }
}

