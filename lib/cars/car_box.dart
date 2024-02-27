import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../style/app_style.dart';

Widget carBox(Function(String carName)? onTap, QueryDocumentSnapshot doc) {
  final carName = doc["carName"] as String;

  return InkWell(
    onTap: () {
      if (onTap != null) {
        onTap(carName);
      }
    },
    child: Card(
      elevation: 4,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.grey[100], // Background color
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: FutureBuilder<String?>(
                future: getImageUrlForCurrentUser(doc),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Icon(Icons.error_outline, size: 120);
                  } else if (snapshot.hasData) {
                    return Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Icon(Icons.image, size: 120);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  doc["carName"],
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 28.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<String?> getImageUrlForCurrentUser(QueryDocumentSnapshot carDoc) async {
      // Access the "UserData" document and retrieve the "imageUrl" field
      String? imageUrl = carDoc.get(
          'imageUrl'); // these 2 lines creating error
      return imageUrl;
    // }
  // }
}

