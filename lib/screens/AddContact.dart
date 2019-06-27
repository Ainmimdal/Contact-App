import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../model/Contact.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart'; //gives path of image


class AddContact extends StatefulWidget {
  String uid;
  AddContact(this.uid);
  @override
  _AddContactState createState() => _AddContactState(uid);
}

class _AddContactState extends State<AddContact> {
  
  final String uid;
  _AddContactState(this.uid);
 
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child("Contact");
  
  String _id ="";
  String _firstName ="";
  String _lastName ="";
  String _phone ="";
  String _email ="";
  String _address ="";
  String _photoUrl = "empty";
  
  saveContact(BuildContext context) async{
    if (_firstName.isNotEmpty && _lastName.isNotEmpty && _phone.isNotEmpty && _email.isNotEmpty && _address.isNotEmpty) {

      Contact contact = Contact(this._firstName, this._lastName, this._phone, this._email, this._address, this._photoUrl);

      //Upload data to database
      await _databaseReference.child(uid).push().set(contact.toJson());

      navigateTolastScreen(context);   
    }else{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Field Required"),
              content: Text("All fields are required"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
      );
    }
  }

  Future pickImage() async{
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 200.0,
      maxWidth: 200.0
    );

    String fileName = basename(file.path);
    uploadImage(file , fileName);
  }

   void uploadImage(File file , String fileName) async{

     //Storage ref
     StorageReference storageReference = FirebaseStorage.instance.ref().child(uid).child(fileName);

     storageReference.putFile(file).onComplete.then((firebaseFile) async{
       var downloadUrl = await firebaseFile.ref.getDownloadURL();

       setState(() {
                _photoUrl = downloadUrl;
              });
     });
  }

  navigateTolastScreen(context){
    //Moves to last screen
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Contact"),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  onTap: (){
                    this.pickImage();
                  },
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _photoUrl == "empty" ? AssetImage("images/logo.png") :NetworkImage(_photoUrl),
                        )
                      ),
                    ),
                  ),
                ),
              ),
              //First Name
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                         _firstName = value;                 
                     });
                  },
                  decoration: InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(
                      borderRadius:BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              //Last Name
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                         _lastName = value;                 
                     });
                  },
                  decoration: InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(
                      borderRadius:BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              //phone
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                         _phone = value;                 
                     });
                  },
                  decoration: InputDecoration(
                    labelText: "Phone",
                    border: OutlineInputBorder(
                      borderRadius:BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),
              //Email
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                         _email = value;                 
                     });
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius:BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),
              //address
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                         _address = value;                 
                     });
                  },
                  decoration: InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(
                      borderRadius:BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              //Save
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
                  onPressed: (){
                    this.saveContact(context);
                  },
                  color:Colors.deepOrangeAccent,
                  child: Text("Save",style: TextStyle(color: Colors.white,fontSize:20.0,),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}