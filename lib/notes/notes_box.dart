import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../style/app_style.dart';

Widget noteBox(Function()? onTap, QueryDocumentSnapshot doc) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: AppStyle.cardsColor[doc['color_id']],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doc["note_title"],
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            doc["creation_date"],
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            doc["remarks"],
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16.0,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3, // Limit the number of lines displayed
          ),
        ],
      ),
    ),
  );
}




