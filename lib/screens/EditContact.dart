import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import '../model/Contact.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class EditContact extends StatefulWidget {

  final String id , userID;
  EditContact(this.id,this.userID);
  @override
  _EditContactState createState() => _EditContactState(id,userID);
}

class _EditContactState extends State<EditContact> {
   String id, userID;
  _EditContactState(this.id,this.userID);

  String _firstName ="";
  String _lastName ="";
  String _phone ="";
  String _email ="";
  String _address ="";
  String _photoUrl;

  //handle Text Editing Controller
  TextEditingController _fnController = TextEditingController();
  TextEditingController _lnController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  
  bool isLoading = true;
  
  //Ref
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference().child("Contact");

  @override
    void initState() {
      super.initState();

      //get Contact from firebase
      this.getContact(id);
    }

    //Get contact
    getContact(id) async{
       Contact contact ;
      _databaseReference.child(userID).child(id).onValue.listen((event){
                //coming in a JSON format
              contact = Contact.fromSnapshot(event.snapshot);
               _fnController.text = contact.firstName;
               _lnController.text = contact.lastName;
               _phoneController.text = contact.phone;
               _emailController.text = contact.email;
               _addressController.text = contact.address;
               

                setState(() {
                  _firstName = contact.firstName;                  
                  _lastName = contact.lastName;                  
                  _phone = contact.phone;                  
                  _email = contact.email;                  
                  _address = contact.address;
                  _photoUrl =contact.photoUrl;
                  isLoading = false;                  
                });
    });
    }


    updateContact(context) async{
      if (_firstName.isNotEmpty && _lastName.isNotEmpty && _phone.isNotEmpty && _email.isNotEmpty && _address.isNotEmpty) {
        Contact contact =Contact.withId(this.id, this._firstName, this._lastName, this._phone, this._email, this._address, this._photoUrl);

        //update
        await _databaseReference.child(userID).child(id).set(contact.toJson());
        navigateToLastScreen(context);
      }else{
         showDialog(
          context:  context,
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

    //pick Image 
    Future pickImage() async{
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 200.0,
      maxWidth: 200.0
    );

    String fileName = basename(file.path);
    uploadImage(file , fileName);
  }
    
    //upload image
    void uploadImage(File file , String fileName) async{

     //Storage ref
     StorageReference storageReference = FirebaseStorage.instance.ref().child(userID).child(fileName);
      //upload image
     storageReference.putFile(file).onComplete.then((firebaseFile) async{
       var downloadUrl = await firebaseFile.ref.getDownloadURL();

       setState(() {
                _photoUrl = downloadUrl;
              });
     });
    }

    navigateToLastScreen(context){
        Navigator.pop(context);
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Contact"),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(20.0),
                child: ListView(
                  children: <Widget>[
                    //image view
                    Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            this.pickImage();
                          },
                          child: Center(
                            child: Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image: _photoUrl == "empty"
                                          ? AssetImage("images/logo.png")
                                          : NetworkImage(_photoUrl),
                                    ))),
                          ),
                        )),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _firstName = value;
                          });
                        },
                        controller: _fnController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _lastName = value;
                          });
                        },
                        controller: _lnController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _address = value;
                          });
                        },
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    // update button
                    Container(
                      padding: EdgeInsets.only(top: 20.0),
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(100.0, 20.0, 100.0, 20.0),
                        onPressed: () {
                          updateContact(context);
                        },
                        color: Colors.red,
                        child: Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}