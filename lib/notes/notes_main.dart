import 'package:flutter/material.dart';
import '../components/menu_bar.dart';
import 'notes_box.dart';
import '../style/app_style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notes_box.dart';
import 'note_reader.dart';
import 'note_editor.dart';
import '../reminders/reminder_screen.dart';
import '../notes_screen.dart';
import '../gallery/gallery_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import '../style/theme_class.dart';
import 'package:provider/provider.dart';
import '../style/customBottomNavigation.dart';
import '../style/navigationNotes.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';



class NotesMain extends StatefulWidget {
  final String carName;

  // const NotesMain({super.key});
  const NotesMain({Key? key, required this.carName}) : super(key: key);

  @override
  State<NotesMain> createState() => _NotesMainState();
}

class _NotesMainState extends State<NotesMain> {
  int _currentIndex = 0;
  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  TextEditingController _searchController = TextEditingController();
  bool isSearching = false; // Flag to track whether the user is searching
  List<String> suggestions = []; // List to store the search suggestions
  final CollectionReference notesCollection = FirebaseFirestore.instance.collection("Notes");
  String selectedNoteTitle = "All"; // Initialize with "All" as the default

  void navigateToNewScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteEditorScreen(carName: widget.carName);
    }));
  }


  ListView _buildSuggestions(List<String> suggestions) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            // Perform an action when a suggestion is tapped
            // For example, you can navigate to a specific note based on the suggestion.
          },
        );
      },
    );
  }


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
        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: NotesScreen()));
        // Navigator.push(context, MaterialPageRoute(builder: (context) => NotesScreen()));
        break;
      case 1:
        Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight, child: ReminderScreen()));
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ReminderScreen()));
        break;
    // Add more cases for other screens
      case 2:
      // Navigate to the My Logo screen
        setState(() {
          isDarkAppBar = !isDarkAppBar; // Toggle between white and black
        });
      //   isDarkAppBar // call the functions
      //       ? themeProvider.setLightMode()
      //       : themeProvider.setDarkmode();
        _currentIndex = 0;
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

  bool isDarkAppBar = true;
  @override
  Widget build(BuildContext context) {
    String carName = widget.carName;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: isDarkAppBar ? Colors.black : Colors.white,
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,// Use the appropriate back icon
          ),
          onPressed: () {
            // Handle the back button press
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("UserData").where(
              "email", isEqualTo: userEmail).where("carName", isEqualTo: carName).snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error ${snapshot.error}');
            }

            String carName = 'Name'; // Default value

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final docData = snapshot.data!.docs.first.data() as Map<
                  String,
                  dynamic>;
              if (docData.containsKey('carName')) {
                carName = docData['carName'];
              }
            }

            int startIndex = carName.length > 2 ? carName.length - 3 : 0;
            String frontCharacters = carName.substring(0, startIndex);
            String lastThreeCharacters = carName.substring(startIndex);

            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: frontCharacters,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 30.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: lastThreeCharacters,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 30.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
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
                stream: FirebaseFirestore.instance
                    .collection("Notes")
                    .where("email", isEqualTo: userEmail)
                    .where("carName", isEqualTo: carName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasData) {
                    final notes = snapshot.data!.docs;

                    // Extract note titles
                    final noteTitles = [
                      "All",
                      ...notes.map((noteDoc) => noteDoc["note_title"] as String),
                    ];

                    return Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                          child: Row(
                            children: noteTitles.toSet().map((noteTitle) {
                              return Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: noteTitle == selectedNoteTitle ? Colors.blue : Colors.transparent,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedNoteTitle = noteTitle;
                                    });
                                  },
                                  child: Text(
                                    noteTitle,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: noteTitle == selectedNoteTitle ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: selectedNoteTitle == "All"
                                ? FirebaseFirestore.instance.collection("Notes")
                                .where("email", isEqualTo: userEmail)
                                .where("carName", isEqualTo: carName)
                                .snapshots()
                                : FirebaseFirestore.instance.collection("Notes")
                                .where("email", isEqualTo: userEmail)
                                .where("carName", isEqualTo: carName)
                                .where("note_title", isEqualTo: selectedNoteTitle)
                                .snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (snapshot.data!.docs.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                      "There are no notes",
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              if (snapshot.hasData) {
                                return GridView(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  children: snapshot.data!.docs.map((note) => noteBox(() {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NoteReaderScreen(note)));
                                  }, note)).toList(),
                                );
                              }

                              return Text("There are no notes");
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Text("There are no matching notes");
                },
              ),
            ),

          ],
        ),
      ),

      backgroundColor: Colors.grey[200],

      bottomNavigationBar: CustomBottomNavigation2(
        addingThings: navigateToNewScreen,
        carName: widget.carName,
        cameraFunction: cameraFunction,
      ),
    );
  }
}
