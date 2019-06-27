import 'package:flutter/material.dart';
import 'AddContact.dart';
import 'ViewContact.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //init firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance; //Create connection with firebase
  bool isUserIdNull = true;
  FirebaseUser user;
  bool isSignedIn = false;
  checkAuthemtication() async {
    _auth.onAuthStateChanged.listen((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, "/SignInPage");
      }
    });
  }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isSignedIn = true;
        this.isUserIdNull = false;
      });
    }
  }

  signOut() async {
    _auth.signOut();
  }

  //Reference of firebase database
  DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child("Contact");

  navigateToAddScreen(uid) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddContact(uid);
    }));
  }

  //Need to pass ID
  navigateToViewScreen(id, uid) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ViewContact(id, uid);
    }));
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthemtication();
    this.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        actions: <Widget>[
          IconButton(
            tooltip: "Logout",
            onPressed: (){
              signOut();
            },
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
          ),
        ],
      ),
      body:Center(
              child: isUserIdNull ? CircularProgressIndicator() : Container(
          child: FirebaseAnimatedList(
            query: _databaseReference.child(user.uid),
            itemBuilder: (BuildContext contxt, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return GestureDetector(
                onTap: () {
                  navigateToViewScreen(snapshot.key, user.uid);
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: snapshot.value['photoUrl'] == "empty"
                                    ? AssetImage("images/logo.png")
                                    : NetworkImage(snapshot.value['photoUrl']),
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${snapshot.value['firstName']} ${snapshot.value['lastName']}",
                                style: TextStyle(
                                    fontSize: 20.0, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${snapshot.value['phone']}",
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          navigateToAddScreen(user.uid);
        },
      ),
    );
  }
}
