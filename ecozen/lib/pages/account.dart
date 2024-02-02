import 'package:ecozen/sercureStorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  TextEditingController _backendURLController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/10-removebg-preview.png', // Replace with the path to your image asset
            width: 350, // Adjust the width as needed
            height: 400, // Adjust the height as needed
          ),
          SizedBox(height: 30),
          ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: Text("Logout")),
          Padding(
            padding: const EdgeInsets.only(left: 30,right: 30),
            child: TextField(controller: _backendURLController,decoration: InputDecoration(hintText: "http://172.20.10.14:8000"),),
          ),
          const SizedBox(height: 5,),
          ElevatedButton(onPressed: () async{
            await secureStorage.write(key: "backendURL", value: _backendURLController.text.toString());
          }, child: Text("Change URL"),),
        ],
      ),
    );
  }
}
