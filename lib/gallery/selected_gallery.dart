import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_navigator.dart';
import '../components/menu_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../notes_screen.dart';
import '../reminders/reminder_screen.dart';
import '../addCar.dart';
import '../cars/car_box.dart';
import '../notes/notes_main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../style/app_style.dart';
import 'package:page_transition/page_transition.dart';
import '../pages/login_or_register.dart';
import '../pages/auth_page.dart';
import '../services/auth_service.dart';
import '../style/theme_class.dart';
import 'package:provider/provider.dart';
import '../style/customBottomNavigation.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'gallery_box.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


class GalleryScreen2 extends StatefulWidget {
  final String carName;

  const GalleryScreen2({super.key, required this.carName});

  @override
  State<GalleryScreen2> createState() => _GalleryScreen2State();
}

class _GalleryScreen2State extends State<GalleryScreen2> {
  int _currentIndex = 4;
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  TextEditingController searchController = TextEditingController();
  String query = ''; // Define query at the top of your widget's build method or as a member variable in your State class

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

  Future<void> navigateToNewScreen(BuildContext context) async {
    await _pickImage();

    if (_selectedImage != null) {
      String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      imageUrl = await uploadImageToStorage(_selectedImage!);

      if (imageUrl != null) {
        // Handle the case where the image was uploaded successfully
        print('Uploaded image URL: $imageUrl');

        // Show a snackbar with a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploaded successfully'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),
        );

        // Detect text from the selected image
        String detectedText = await detectTextInImage(_selectedImage!);

        if (detectedText.isNotEmpty) {
          // You can use the detected text as needed
          print('Detected Text: $detectedText');
        }

        // You can also perform any other actions here after the image is uploaded.
        // Save the image URL and detected text to Firestore here.
        await FirebaseFirestore.instance.collection('Gallery').add({
          'email': userEmail,
          'imageUrl': imageUrl,
          'carName': widget.carName,
          'detectedText': detectedText,
        });
      } else {
        // Handle the case where there was an error uploading the image
        print('Failed to upload the image.');

        // Show a snackbar with an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload the image'),
            duration: Duration(seconds: 2), // Adjust the duration as needed
          ),
        );
      }
    } else {
      // Handle the case where no image is selected
      print('No image selected.');

      // Show a snackbar with a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image selected'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }

    // Now you can navigate to another screen if needed.
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      // Return the widget for the new screen here.
      return GalleryScreen2(carName: widget.carName);
    }));
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
        'carName': widget.carName,
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

      String detectedText = await detectTextInImage(pickedImage);

      if (detectedText.isNotEmpty) {
        // You can use the detected text as needed
        print('Detected Text: $detectedText');
      }

      await FirebaseFirestore.instance.collection('Gallery').add({
        'email': userEmail,
        'imageUrl': imageUrl,
        'carName': widget.carName,
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

  Future<String?> getImageUrlForCurrentUser() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      // Query Firestore to get the document for the current user
      QuerySnapshot emailQuery = await FirebaseFirestore.instance
          .collection('UserData')
          .where('email', isEqualTo: userEmail)
          .where('carName', isEqualTo: widget.carName)
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


  void signUserOut() async {
    AuthService().signOut();
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthPage()));
  }

  bool _imagePicked = false;
  XFile? _selectedImage;
  String? imageUrl;
  Future<void> _pickImage() async {

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if(pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _imagePicked = true;
      });
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


  bool isDarkAppBar = true;
  List<Map<String, dynamic>> imageData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
            color: Colors.black,
          )
        ],
        iconTheme: IconThemeData(color: Colors.black), // Change the color of the back button
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.carName + "'s Gallery",
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Colors.grey, // Border color
                        width: 1.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        // When the text in the TextField changes, update the search query here
                        // You can also trigger your search functionality here
                        setState(() {
                          final query = value.toLowerCase();
                        });
                        // print("Search Query: $query");
                        // Perform search or filtering based on the query
                      },
                      decoration: InputDecoration(
                        hintText: "Search Documents",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text("Documents", style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),),
                SizedBox(width: 10), // Add some spacing between the texts
                Text("Long Press to delete", style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("Gallery").where("email", isEqualTo: userEmail).where("carName", isEqualTo: widget.carName).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if(snapshot.hasData) {
                    // Filter the documents based on the search query
                    final query = searchController.text.toLowerCase();
                    print("this is testing $query");

                    final filteredDocs = query.isEmpty
                        ? snapshot.data!.docs.toList() // Show all images when the search query is empty
                        : snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final detectedText = data.containsKey('detectedText')
                          ? data['detectedText'].toString().toLowerCase()
                          : ''; // Provide a default value or handle the case where the field doesn't exist
                      print("Detected Text: $detectedText");

                      return detectedText.contains(query);
                    }).toList();


                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredDocs.length,

                      itemBuilder: (context, index) {
                        // String imageUrl = snapshot.data!.docs[index].get('imageUrl');
                        // Map<String, dynamic> imageInfo = {
                        //   'imageUrl': imageUrl,
                        // };
                        // imageData.add(imageInfo);
                        final document = filteredDocs[index];
                        final imageUrl = document.get('imageUrl');
                        Map<String, dynamic> imageInfo = {
                          'imageUrl': imageUrl,
                        };
                        imageData.add(imageInfo);
                        return GestureDetector(
                          onLongPress: () {
                            String? selectedImageUrl = imageInfo['imageUrl'];
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Photo'),
                                  content: Text('Are you sure you want to delete this photo?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                                        QuerySnapshot emailQuery = await FirebaseFirestore.instance
                                            .collection('Gallery')
                                            .where('email', isEqualTo: userEmail)
                                            .where('imageUrl', isEqualTo: selectedImageUrl)
                                            .where('carName', isEqualTo: widget.carName)
                                            .get();

                                        if (emailQuery.docs.isNotEmpty) {
                                          // If a matching document is found, delete it
                                          emailQuery.docs.first.reference.delete();
                                          print('Image deleted from Firestore.');
                                        }
                                        // Delete the photo here, for example, by removing it from Firestore
                                        // Add your code here to delete the photo
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                          },
                          onTap: () {
                            showImageViewer(context, Image.network(imageUrl).image, swipeDismissible: false, doubleTapZoomable: true);
                          },
                          child: Container(
                            margin: EdgeInsets.all(3.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        );
                      },
                    );
                  }
                  return Text("Ther's no car");
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

// front page add milleage
// statistics for changing Engine Oil
// itemCount: snapshot.data!.docs.length,