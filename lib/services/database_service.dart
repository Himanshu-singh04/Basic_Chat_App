import 'package:cloud_firestore/cloud_firestore.dart';

class database_service {
  final String? uid;
  database_service({this.uid});

  final CollectionReference user_collection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference group_collection =
      FirebaseFirestore.instance.collection("groups");
  Future saving_user_data(String full_name, String email) async {
    return await user_collection.doc(uid).set({
      "fullname": full_name,
      "email": email,
      "groups": [],
      "profile_pic": "",
      "uid": uid,
    });
  }

  Future getting_user_data(String email) async {
    QuerySnapshot snapshot =
        await user_collection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  get_user_groups() async {
    return user_collection.doc(uid).snapshots();
  }

  Future create_group(String user_name, String id, String group_name) async {
    DocumentReference groupdocumentReference = await group_collection.add({
      "groupname": group_name,
      "groupicon": "",
      "admin": "${id}_$user_name",
      "members": [],
      "groupid": "",
      "recentmessage": "",
      "recentmessagesender": "",
    });

    await groupdocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$user_name"]),
      "groupid": groupdocumentReference.id
    });
    DocumentReference user_document_reference = user_collection.doc(uid);
    return await user_document_reference.update({
      "groups":
          FieldValue.arrayUnion(["${groupdocumentReference.id}_$group_name"])
    });
  }
}
