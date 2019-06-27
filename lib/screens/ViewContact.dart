import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'EditContact.dart';
import '../model/Contact.dart';
import 'package:url_launcher/url_launcher.dart';
class ViewContact extends StatefulWidget {

  final String id, userID;

  ViewContact(this.id,this.userID);
  @override
  _ViewContactState createState() => _ViewContactState(id,userID);
}

class _ViewContactState extends State<ViewContact> {


  //Ref
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child("Contact");

  String id , userID;
  _ViewContactState(this.id,this.userID);
  Contact _contact ;
  bool isLoading = true;

  getContact(id) async{
    _databaseReference.child(userID).child(id).onValue.listen((event){
      setState(() {
                //coming in a JSON format
              _contact = Contact.fromSnapshot(event.snapshot);
               isLoading = false;
            });
    });
  }

  @override
    void initState() {      
      super.initState();
      this.getContact(id);
    }

    //Call intent
    callAction(String number) async{
      String url = 'tel:$number';
      if(await canLaunch(url)){
        await  launch(url);
      }else{
        throw 'Could not call $number';
      }
    }

    //message intent
    smsAction(String number) async{
      String url = 'sms:$number';
      if(await canLaunch(url)){
        await  launch(url);
      }else{
        throw 'Could not send message to  $number';
      }
    }

    deleteContact() async{
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Delete"),
            content: Text("Delete Contact"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancle"),
                onPressed:(){
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Delete"),
                onPressed:() async{
                  Navigator.of(context).pop();
                  //Delete contact
                  await _databaseReference.child(userID).child(id).remove();
                  navigateToLastScreen();
                },
              ),
            ],

          );
        }
      );
    }

    navigateToEditScreen(id,uid){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return EditContact(id,uid);
        }));
    }
    navigateToLastScreen(){
      Navigator.pop(context);
    }


  @override
  Widget build(BuildContext context) {
    // wrap screen in WillPopScreen widget
    return Scaffold(
      appBar: AppBar(
        title: Text("View Contact"),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  // header text container
                  Container(
                      height: 200.0,
                      child: Image(
                        //
                        image: _contact.photoUrl == "empty"
                            ? AssetImage("images/logo.png")
                            : NetworkImage(_contact.photoUrl),
                        fit: BoxFit.contain,
                      )),
                  //name
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.perm_identity),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              "${_contact.firstName} ${_contact.lastName}",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // phone
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.phone),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contact.phone,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // email
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.email),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contact.email,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // address
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.home),
                            Container(
                              width: 10.0,
                            ),
                            Text(
                              _contact.address,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
                        )),
                  ),
                  // call and sms
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.phone),
                              color: Colors.red,
                              onPressed: () {
                                callAction(_contact.phone);
                              },
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.message),
                              color: Colors.red,
                              onPressed: () {
                                smsAction(_contact.phone);
                              },
                            )
                          ],
                        )),
                  ),
                  // edit and delete
                  Card(
                    elevation: 2.0,
                    child: Container(
                        margin: EdgeInsets.all(20.0),
                        width: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.edit),
                              color: Colors.red,
                              onPressed: () {
                                navigateToEditScreen(id,userID);
                              },
                            ),
                            IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                deleteContact();
                              },
                            )
                          ],
                        )),
                  )
                ],
              ),
      ),
    );
  }
}