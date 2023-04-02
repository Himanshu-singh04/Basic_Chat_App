import 'package:chatapp/helper/helper.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/pages/profile_page.dart';
import 'package:chatapp/pages/search_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/database_service.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/group_tile.dart';

class home_page extends StatefulWidget {
  const home_page({super.key});

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  String username = "";
  String email = "";
  auth_service authservice = auth_service();
  Stream? groups;
  bool is_loading = false;
  String group_name = "";

  @override
  void initState() {
    super.initState();
    getting_user_data();
  }

  String getid(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getname(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getting_user_data() async {
    await Helper_functions.get_user_email_from_SF().then((value_email) {
      setState(() {
        email = value_email!;
      });
    });
    await Helper_functions.get_user_name_from_SF().then((value_username) {
      setState(() {
        username = value_username!;
      });
    });

    await database_service(uid: FirebaseAuth.instance.currentUser!.uid)
        .get_user_groups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              next_screen(context, search_screen());
            },
            icon: Icon(Icons.search),
          )
        ],
        centerTitle: true,
        title: Text(
          "Groups",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(
              height: 30,
            ),
            Divider(height: 3),
            ListTile(
              onTap: () {},
              selectedColor: Colors.cyan,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                next_screen_replace(
                    context,
                    profile_page(
                      username: username,
                      email: email,
                    ));
              },
              selectedColor: Colors.cyan,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("logout"),
                        content: Text("are you sure you want to logout ??"),
                        actions: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () async {
                                await authservice.sign_out();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => login_page()),
                                    (route) => false);
                              },
                              icon: Icon(
                                Icons.done,
                                color: Colors.green,
                              ))
                        ],
                      );
                    });
              },
              selectedColor: Colors.cyan,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.exit_to_app),
              title: Text(
                "LogOut",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: group_list(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pop_up_dialog(context);
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  pop_up_dialog(BuildContext context) {
    showDialog(
        barrierDismissible: kFlutterMemoryAllocationsEnabled,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: Text(
                "Create a new group",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  is_loading == true
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              group_name = val;
                            });
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular(30)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(30)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular(30))),
                        )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (group_name != "") {
                      setState(() {
                        is_loading = true;
                      });
                      database_service(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .create_group(
                              username,
                              FirebaseAuth.instance.currentUser!.uid,
                              group_name)
                          .whenComplete(() {
                        is_loading = false;
                      });
                      Navigator.of(context).pop();
                      snack_bar(context, Colors.green, "group created");
                    }
                  },
                  child: Text("create"),
                ),
              ],
            );
          }));
        });
  }

  group_list() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      groupid: getid(snapshot.data['groups'][reverseIndex]),
                      groupname: getname(snapshot.data['groups'][reverseIndex]),
                      username: snapshot.data['fullName']);
                },
              );
            } else {
              return no_group_widget();
            }
          } else {
            return no_group_widget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  no_group_widget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              pop_up_dialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
